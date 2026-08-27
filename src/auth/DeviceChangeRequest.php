<?php
/**
 * Pending device-change request workflow, used when a login/Google sign-in
 * comes from a device that isn't the account's currently trusted one.
 */

require_once __DIR__ . '/../database/Database.php';
require_once __DIR__ . '/../security/DeviceFingerprint.php';
require_once __DIR__ . '/AuditLogger.php';

class DeviceChangeRequest {

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
        $db = Database::getInstance();
        $fingerprint_hash = DeviceFingerprint::generateFromData($data);
        $info = DeviceFingerprint::getDeviceInfo($data);

        if (self::hasPending($user['id'], $fingerprint_hash)) {
            return; // Already awaiting admin review, don't create a duplicate
        }

        $db->execute(
            "INSERT INTO device_change_requests (user_id, fingerprint_hash, device_info, ip_address, browser_info) VALUES (?, ?, ?, ?, ?)",
            [$user['id'], $fingerprint_hash, json_encode($info), $info['ip_address'], $info['browser']]
        );

        AuditLogger::log($user['id'], 'device_change_requested', 'user', $user['id']);
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
        $db = Database::getInstance();
        return $db->getResults(
            "SELECT dcr.id, dcr.user_id, dcr.fingerprint_hash, dcr.device_info, dcr.ip_address, dcr.browser_info,
                    dcr.status, dcr.requested_at, u.username, u.full_name, u.email
             FROM device_change_requests dcr
             JOIN users u ON dcr.user_id = u.id
             WHERE dcr.status = 'pending' AND u.supervisor_id = ? AND u.role = 'employee'
             ORDER BY dcr.requested_at DESC",
            [$supervisor_id]
        );
    }

    /**
     * Approve/reject a pending request, trusting the device on approval and forcing
     * a fresh login. Shared by both the admin and manager (supervisor) approval queues.
     */
    public static function resolve($id, $status, $resolver_id) {
        $db = Database::getInstance();

        if (!$id) throw new Exception('Request ID required');

        $request = $db->getRow("SELECT * FROM device_change_requests WHERE id = ? AND status = 'pending'", [$id]);
        if (!$request) throw new Exception('Pending device request not found');

        if ($status === 'approved') {
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
            [$status, $resolver_id, $id]
        );

        AuditLogger::log($resolver_id, "device_request_{$status}", 'device_change_request', $id);

        return ['success' => true, 'message' => "Device request {$status}"];
    }
}
