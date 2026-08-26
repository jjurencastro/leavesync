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
}
