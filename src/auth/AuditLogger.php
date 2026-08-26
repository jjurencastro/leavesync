<?php
/**
 * Security/activity audit logging
 */

require_once __DIR__ . '/../database/Database.php';
require_once __DIR__ . '/../security/DeviceFingerprint.php';

class AuditLogger {
    /**
     * Log a security-relevant action.
     * @param int|null $user_id
     * @param string $action
     * @param string $entity_type
     * @param int|null $entity_id
     * @param array $changes
     */
    public static function log($user_id, $action, $entity_type, $entity_id = null, $changes = []) {
        try {
            $device_info = DeviceFingerprint::getDeviceInfo();
            $db = Database::getInstance();

            $sql = "INSERT INTO audit_log
                    (user_id, action, entity_type, entity_id, ip_address, device_fingerprint, new_values)
                    VALUES (?, ?, ?, ?, ?, ?, ?)";

            $db->execute($sql, [
                $user_id,
                $action,
                $entity_type,
                $entity_id,
                $device_info['ip_address'],
                hash('sha256', json_encode($device_info)),
                json_encode($changes)
            ]);
        } catch (Exception $e) {
            error_log("Audit log error: " . $e->getMessage());
        }
    }
}
