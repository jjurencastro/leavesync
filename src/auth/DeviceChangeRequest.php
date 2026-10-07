<?php
/**
 * Pending device-change request workflow, used when a login/Google sign-in
 * comes from a device that isn't the account's currently trusted one.
 */

require_once __DIR__ . '/../database/Database.php';
require_once __DIR__ . '/../security/DeviceFingerprint.php';
require_once __DIR__ . '/../security/WebAuthnService.php';
require_once __DIR__ . '/AuditLogger.php';
require_once __DIR__ . '/../leave/ApprovalChain.php';
require_once __DIR__ . '/../database/SchemaSupport.php';

class DeviceChangeRequest {

    /**
     * Older databases predate the assigned_approver_id column, which makes every
     * device-request query fail. Add it on demand when it is missing.
     */
    private static function ensureApproverColumn() {
        $db = Database::getInstance();
        if (SchemaSupport::hasColumn($db, 'device_change_requests', 'assigned_approver_id')) {
            return;
        }
        try {
            $db->getConnection()->query("ALTER TABLE device_change_requests ADD COLUMN assigned_approver_id INT NULL");
            $db->getConnection()->query("ALTER TABLE device_change_requests ADD INDEX idx_assigned_approver_id (assigned_approver_id)");
        } catch (Throwable $e) {
            error_log('Could not add assigned_approver_id column: ' . $e->getMessage());
        }
    }

    /**
     * Whether the user already has a pending device-change request for this
     * exact device fingerprint, so callers can avoid creating duplicates.
     */
    public static function hasPending($user_id, $fingerprint_hash) {
        $db = Database::getInstance();
        $existing = $db->getRow(
            "SELECT id FROM device_change_requests WHERE user_id = ? AND fingerprint_hash = ? AND status = 'pending'",
            [$user_id, $fingerprint_hash]
        );
        return !empty($existing);
    }

    /**
     * Submit a pending device-change request for administrator approval,
     * instead of trusting (or auto-verifying) an unrecognized device.
     */
    public static function create($user, array $data) {
        $assignedApproverId = null;
        try {
            self::ensureApproverColumn();
            $db = Database::getInstance();
            $fingerprint_hash = DeviceFingerprint::generateFromData($data);
            $info = DeviceFingerprint::getDeviceInfo($data);

            if (self::hasPending($user['id'], $fingerprint_hash)) {
                return; // Already awaiting admin review, don't create a duplicate
            }

            // Determine who should approve: supervisor if available, else backup approver/HR
            if (!empty($user['supervisor_id'])) {
                try {
                    $filedDate = date('Y-m-d');
                    $assignment = ApprovalChain::resolveFirstAvailable($db, $user['id'], $filedDate);
                    if ($assignment) {
                        $assignedApproverId = $assignment['id'];
                    }
                } catch (Exception $e) {
                    error_log("Warning: Could not resolve approver for device request: " . $e->getMessage());
                    // Fallback: assign to supervisor if available
                    $assignedApproverId = $user['supervisor_id'] ?? null;
                }
            }

            $db->execute(
                "INSERT INTO device_change_requests (user_id, fingerprint_hash, device_info, ip_address, browser_info, assigned_approver_id) VALUES (?, ?, ?, ?, ?, ?)",
                [$user['id'], $fingerprint_hash, json_encode($info), $info['ip_address'], $info['browser'], $assignedApproverId]
            );
        } catch (Exception $e) {
            error_log("Failed to create device change request: " . $e->getMessage());
            // Don't rethrow - allow login to continue even if device request fails
        }

        AuditLogger::log($user['id'], 'device_change_requested', 'user', $user['id']);
        
        // Notify approvers (don't fail if notification errors occur)
        try {
            // Fetch full user record with supervisor info for notification
            $db = Database::getInstance();
            $fullUser = $db->getRow(
                "SELECT id, username, email, full_name, role, supervisor_id FROM users WHERE id = ?",
                [$user['id']]
            );
            if ($fullUser) {
                self::notifyApprovers($fullUser, $assignedApproverId);
            }
        } catch (Exception $e) {
            error_log("Device request notification error: " . $e->getMessage());
        }
    }

    /**
     * Get the details of a pending Google-login device change awaiting the
     * user's confirmation (stashed in the native PHP session by GoogleAuth).
     */
    public static function getPendingInfo() {
        session_start();
        $user_id = $_SESSION['pending_device_change_user_id'] ?? null;

        if (!$user_id) {
            return ['success' => false, 'message' => 'No pending device change request.'];
        }

        $data = $_SESSION['pending_device_change_data'] ?? [];
        $changes = DeviceFingerprint::diffAgainstTrusted($user_id, DeviceFingerprint::getDeviceInfo($data), true);

        return ['success' => true, 'changes' => $changes];
    }

    /**
     * User confirmed they want to request approval for the pending Google-login device change.
     */
    public static function confirmPending() {
        session_start();
        $user_id = $_SESSION['pending_device_change_user_id'] ?? null;

        if (!$user_id) {
            return ['success' => false, 'message' => 'No pending device change request.'];
        }

        $data = $_SESSION['pending_device_change_data'] ?? [];
        $user = Database::getInstance()->getRow("SELECT id, username, email FROM users WHERE id = ?", [$user_id]);

        self::create($user, $data);
        unset($_SESSION['pending_device_change_user_id'], $_SESSION['pending_device_change_data']);

        return ['success' => true, 'message' => 'Device change request submitted for administrator approval.'];
    }

    /**
     * User declined to request approval for the pending Google-login device change.
     */
    public static function cancelPending() {
        session_start();
        unset($_SESSION['pending_device_change_user_id'], $_SESSION['pending_device_change_data']);
        return ['success' => true];
    }

    /**
     * Pending requests from Tier 2/3 (manager/hr) accounts, and Tier 1 accounts with
     * no supervisor on file, which only the System Administrator can approve.
     */
    public static function getPendingForAdmin() {
        self::ensureApproverColumn();
        $db = Database::getInstance();
        return $db->getResults(
            "SELECT dcr.id, dcr.user_id, dcr.fingerprint_hash, dcr.device_info, dcr.ip_address, dcr.browser_info,
                    dcr.status, dcr.requested_at, u.username, u.full_name, u.email
             FROM device_change_requests dcr
             JOIN users u ON dcr.user_id = u.id
             WHERE dcr.status = 'pending' AND (u.role IN ('manager', 'hr', 'admin') OR u.supervisor_id IS NULL)
             ORDER BY dcr.requested_at DESC"
        );
    }

    /**
     * Pending requests from a manager's own direct reports (Tier 1 employees who chose them as supervisor).
     */
    public static function getPendingForSupervisor($supervisor_id) {
        self::ensureApproverColumn();
        $db = Database::getInstance();
        return $db->getResults(
            "SELECT dcr.id, dcr.user_id, dcr.fingerprint_hash, dcr.device_info, dcr.ip_address, dcr.browser_info,
                    dcr.status, dcr.requested_at, u.username, u.full_name, u.email, dcr.assigned_approver_id
             FROM device_change_requests dcr
             JOIN users u ON dcr.user_id = u.id
             WHERE dcr.status = 'pending' AND (dcr.assigned_approver_id = ? OR (u.supervisor_id = ? AND dcr.assigned_approver_id IS NULL)) AND u.role = 'employee'
             ORDER BY dcr.requested_at DESC",
            [$supervisor_id, $supervisor_id]
        );
    }

    /**
     * Pending requests from an HR user's own direct reports (e.g. Deans, who
     * report to HR per the approval hierarchy). Tier is not restricted here:
     * an HR user's direct reports are never Tier 1 employees.
     */
    public static function getPendingForHR($hr_id) {
        self::ensureApproverColumn();
        $db = Database::getInstance();
        return $db->getResults(
            "SELECT dcr.id, dcr.user_id, dcr.fingerprint_hash, dcr.device_info, dcr.ip_address, dcr.browser_info,
                    dcr.status, dcr.requested_at, u.username, u.full_name, u.email, dcr.assigned_approver_id
             FROM device_change_requests dcr
             JOIN users u ON dcr.user_id = u.id
             WHERE dcr.status = 'pending' AND dcr.assigned_approver_id = ?
             ORDER BY dcr.requested_at DESC",
            [$hr_id]
        );
    }

    /**
     * Approve/reject a pending request, trusting the device on approval and forcing
     * a fresh login. Shared by both the admin and manager (supervisor) approval queues.
     * Approval requires a passkey assertion; rejection does not.
     */
    public static function resolve($id, $status, $resolverUser, $webauthnResponse = null) {
        $db = Database::getInstance();

        if (!$id) throw new Exception('Request ID required');

        $request = $db->getRow("SELECT * FROM device_change_requests WHERE id = ? AND status = 'pending'", [$id]);
        if (!$request) throw new Exception('Pending device request not found');

        if ($status === 'approved') {
            if (empty($webauthnResponse)) {
                throw new Exception('A passkey approval is required to approve this request.');
            }
            WebAuthnService::verifyApproval($resolverUser, $webauthnResponse, 'device_change', (int) $id);

            DeviceFingerprint::trustFingerprint(
                $request['user_id'],
                $request['fingerprint_hash'],
                $request['device_info'],
                $request['ip_address'],
                $request['browser_info']
            );

            // Force logout everywhere so the user must sign in again from the newly trusted device
            $db->execute("DELETE FROM sessions WHERE user_id = ?", [$request['user_id']]);
        }

        $db->execute(
            "UPDATE device_change_requests SET status = ?, resolved_at = NOW(), resolved_by = ? WHERE id = ?",
            [$status, $resolverUser['id'], $id]
        );

        AuditLogger::log($resolverUser['id'], "device_request_{$status}", 'device_change_request', $id);
        
        // Notify the user (don't fail if notification errors occur)
        try {
            self::notifyUser($request['user_id'], $status);
        } catch (Exception $e) {
            error_log("Device request resolution notification error: " . $e->getMessage());
        }

        return ['success' => true, 'message' => "Device request {$status}"];
    }

    /**
     * Create a notification for the user and notify approvers
     */
    private static function notifyApprovers($user, $assignedApproverId = null) {
        try {
            $db = Database::getInstance();
            
            // Find who needs to approve
            if (!empty($assignedApproverId)) {
                // Notify whoever the request was actually assigned to (supervisor, HR, or backup)
                $approvers = $db->getResults(
                    "SELECT id, email, full_name FROM users WHERE id = ? AND is_active = 1",
                    [$assignedApproverId]
                );
            } elseif ($user['role'] === 'admin' || $user['role'] === 'hr' || empty($user['supervisor_id'])) {
                // Admin users and users with no supervisor need System Admin approval
                $approvers = $db->getResults(
                    "SELECT id, email, full_name FROM users WHERE role = 'admin' AND is_active = 1"
                );
            } elseif ($user['role'] === 'manager') {
                // Managers need Admin approval
                $approvers = $db->getResults(
                    "SELECT id, email, full_name FROM users WHERE role = 'admin' AND is_active = 1"
                );
            } else {
                // Employees: notify their supervisor first
                if (!empty($user['supervisor_id'])) {
                    $approvers = $db->getResults(
                        "SELECT id, email, full_name FROM users WHERE id = ? AND is_active = 1",
                        [$user['supervisor_id']]
                    );
                } else {
                    $approvers = [];
                }
            }

            // Tell the primary supervisor their request was escalated while they're unavailable
            if (!empty($assignedApproverId) && !empty($user['supervisor_id'])
                && (int) $user['supervisor_id'] !== (int) $assignedApproverId
                && !in_array($user['role'], ['admin', 'hr', 'manager'], true)) {
                self::createNotification(
                    $user['supervisor_id'],
                    'Device Change Request Escalated',
                    "A device change request from {$user['full_name']} has been escalated to a backup approver because you are unavailable.",
                    'device_change'
                );
            }

            // Create notifications
            if (!empty($approvers)) {
                foreach ($approvers as $approver) {
                    self::createNotification(
                        $approver['id'],
                        'New Device Change Request',
                        "{$user['full_name']} is requesting approval to use a new device",
                        'device_change'
                    );
                }
            }
        } catch (Exception $e) {
            error_log("Failed to notify approvers for device request: " . $e->getMessage());
        }
    }

    /**
     * Notify the user their device request was approved/rejected
     */
    private static function notifyUser($user_id, $status) {
        $db = Database::getInstance();
        $user = $db->getRow("SELECT full_name FROM users WHERE id = ?", [$user_id]);
        
        if (!$user) return;

        $title = $status === 'approved' ? 'Device Approved' : 'Device Request Rejected';
        $message = $status === 'approved'
            ? 'Your device change request has been approved. You will need to log in again.'
            : 'Your device change request has been rejected.';

        self::createNotification($user_id, $title, $message, 'device_change');
    }

    /**
     * Create a notification in the database
     */
    private static function createNotification($user_id, $title, $message, $type) {
        $db = Database::getInstance();
        $db->execute(
            "INSERT INTO notifications (user_id, title, message, notification_type, related_entity_type) 
             VALUES (?, ?, ?, ?, ?)",
            [$user_id, $title, $message, 'info', $type]
        );
    }
}
