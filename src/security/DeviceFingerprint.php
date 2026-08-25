<?php
/**
 * Device Fingerprinting for Enhanced Security
 */

class DeviceFingerprint {

    /**
     * Generate a device fingerprint based on browser and system characteristics
     * @param array $data Optional browser/device data supplied by the client
     * @return string Device fingerprint hash
     */
    public static function generateFromData(array $data = []) {
        $fingerprint_data = self::buildFingerprintData($data);
        return hash('sha256', json_encode($fingerprint_data));
    }

    public static function generate() {
        return self::generateFromData();
    }

    /**
     * Get device fingerprint details
     * @param array $data Optional browser/device data supplied by the client
     * @return array Device information
     */
    public static function getDeviceInfo(array $data = []) {
        return self::buildFingerprintData($data);
    }

    /**
     * Get client IP address
     * @return string IP address
     */
    private static function getClientIP() {
        if (!empty($_SERVER['HTTP_CF_CONNECTING_IP'])) {
            return $_SERVER['HTTP_CF_CONNECTING_IP'];
        } elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
            $ips = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
            return trim($ips[0]);
        } elseif (!empty($_SERVER['HTTP_X_FORWARDED'])) {
            return $_SERVER['HTTP_X_FORWARDED'];
        } elseif (!empty($_SERVER['HTTP_FORWARDED_FOR'])) {
            return $_SERVER['HTTP_FORWARDED_FOR'];
        } elseif (!empty($_SERVER['HTTP_FORWARDED'])) {
            return $_SERVER['HTTP_FORWARDED'];
        } else {
            return $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
        }
    }

    /**
     * Extract browser information from user agent
     * @return string Browser name and version
     */
    private static function getBrowserInfo() {
        $ua = $_SERVER['HTTP_USER_AGENT'] ?? '';

        if (strpos($ua, 'Chrome') !== false) {
            preg_match('/Chrome\/(\d+)/', $ua, $matches);
            return 'Chrome ' . ($matches[1] ?? 'unknown');
        } elseif (strpos($ua, 'Firefox') !== false) {
            preg_match('/Firefox\/(\d+)/', $ua, $matches);
            return 'Firefox ' . ($matches[1] ?? 'unknown');
        } elseif (strpos($ua, 'Safari') !== false) {
            preg_match('/Safari\/(\d+)/', $ua, $matches);
            return 'Safari ' . ($matches[1] ?? 'unknown');
        } elseif (strpos($ua, 'Edge') !== false) {
            preg_match('/Edge\/(\d+)/', $ua, $matches);
            return 'Edge ' . ($matches[1] ?? 'unknown');
        } else {
            return 'Unknown';
        }
    }

    /**
     * Extract OS information from user agent
     * @return string Operating system
     */
    private static function getOSInfo() {
        $ua = $_SERVER['HTTP_USER_AGENT'] ?? '';

        if (strpos($ua, 'Windows NT 10.0') !== false) {
            return 'Windows 10';
        } elseif (strpos($ua, 'Windows NT 6.3') !== false) {
            return 'Windows 8.1';
        } elseif (strpos($ua, 'Windows NT 6.2') !== false) {
            return 'Windows 8';
        } elseif (strpos($ua, 'Mac OS X') !== false) {
            preg_match('/Mac OS X ([\d_]+)/', $ua, $matches);
            return 'macOS ' . str_replace('_', '.', $matches[1] ?? 'unknown');
        } elseif (strpos($ua, 'Linux') !== false) {
            return 'Linux';
        } else {
            return 'Unknown';
        }
    }

    private static function buildFingerprintData(array $data = []) {
        return [
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
            'accept_language' => $_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? '',
            'accept_encoding' => $_SERVER['HTTP_ACCEPT_ENCODING'] ?? '',
            'ip_address' => self::getClientIP(),
            'browser' => self::getBrowserInfo(),
            'os' => self::getOSInfo(),
            'screen_resolution' => $data['screen_resolution'] ?? $_POST['screen_resolution'] ?? 'unknown',
            'timezone' => $data['timezone'] ?? $_POST['timezone'] ?? date_default_timezone_get(),
            'language' => $data['language'] ?? $_POST['language'] ?? '',
            'platform' => $data['platform'] ?? $_POST['platform'] ?? '',
            'hardware_concurrency' => $data['hardware_concurrency'] ?? $_POST['hardware_concurrency'] ?? 'unknown',
            'device_memory' => $data['device_memory'] ?? $_POST['device_memory'] ?? 'unknown',
        ];
    }

    /**
     * Verify device fingerprint against stored fingerprint
     * @param string $stored_fingerprint Stored fingerprint hash
     * @return bool Is fingerprint match valid
     */
    public static function verify($stored_fingerprint) {
        $current_fingerprint = self::generate();
        return hash_equals($stored_fingerprint, $current_fingerprint);
    }

    /**
     * Store device fingerprint in database and mark as trusted if requested
     * @param int $user_id User ID
     * @param bool $is_trusted Mark as trusted device
     * @param array $data Optional browser/device data supplied by the client
     * @return int Device fingerprint ID
     */
    public static function store($user_id, $is_trusted = true, array $data = []) {
        $db = Database::getInstance();
        $fingerprint_hash = self::generateFromData($data);
        $device_info = json_encode(self::getDeviceInfo($data));
        $ip_address = self::getClientIP();
        $browser_info = self::getBrowserInfo();

        $existing = $db->getRow(
            "SELECT id FROM device_fingerprints WHERE user_id = ? AND fingerprint_hash = ?",
            [$user_id, $fingerprint_hash]
        );

        if ($existing) {
            $db->execute(
                "UPDATE device_fingerprints SET is_trusted = ?, last_used = NOW(), device_info = ?, ip_address = ?, browser_info = ? WHERE id = ?",
                [$is_trusted ? 1 : 0, $device_info, $ip_address, $browser_info, $existing['id']]
            );
            return $existing['id'];
        }

        $db->execute(
            "INSERT INTO device_fingerprints (user_id, fingerprint_hash, device_info, ip_address, browser_info, is_trusted) VALUES (?, ?, ?, ?, ?, ?)",
            [$user_id, $fingerprint_hash, $device_info, $ip_address, $browser_info, $is_trusted ? 1 : 0]
        );

        return $db->lastInsertId();
    }

    /**
     * Directly mark an already-known fingerprint hash as trusted, without a live
     * request context. Used when an admin approves a pending device change request.
     * @return int Device fingerprint ID
     */
    public static function trustFingerprint($user_id, $fingerprint_hash, $device_info, $ip_address, $browser_info) {
        $db = Database::getInstance();

        $existing = $db->getRow(
            "SELECT id FROM device_fingerprints WHERE user_id = ? AND fingerprint_hash = ?",
            [$user_id, $fingerprint_hash]
        );

        if ($existing) {
            $db->execute(
                "UPDATE device_fingerprints SET is_trusted = 1, last_used = NOW(), device_info = ?, ip_address = ?, browser_info = ? WHERE id = ?",
                [$device_info, $ip_address, $browser_info, $existing['id']]
            );
            return $existing['id'];
        }

        $db->execute(
            "INSERT INTO device_fingerprints (user_id, fingerprint_hash, device_info, ip_address, browser_info, is_trusted) VALUES (?, ?, ?, ?, ?, 1)",
            [$user_id, $fingerprint_hash, $device_info, $ip_address, $browser_info]
        );

        return $db->lastInsertId();
    }

    /**
     * Determine whether the current device is trusted for a user.
     * @param int $user_id User ID
     * @param array $data Optional browser/device data supplied by the client
     * @return bool True when the current device exists and is marked trusted
     */
    public static function verifyTrustedDevice($user_id, array $data = []) {
        $db = Database::getInstance();
        $fingerprint_hash = self::generateFromData($data);

        $device = $db->getRow(
            "SELECT id FROM device_fingerprints WHERE user_id = ? AND fingerprint_hash = ? AND is_trusted = 1 LIMIT 1",
            [$user_id, $fingerprint_hash]
        );

        return !empty($device);
    }

    /**
     * Get user's trusted devices
     * @param int $user_id User ID
     * @return array Array of trusted devices
     */
    public static function getTrustedDevices($user_id) {
        $sql = "SELECT id, fingerprint_hash, device_info, ip_address, browser_info, last_used 
                FROM device_fingerprints 
                WHERE user_id = ? AND is_trusted = 1
                ORDER BY last_used DESC";

        $db = Database::getInstance();
        return $db->getResults($sql, [$user_id]);
    }

    /**
     * Mark device as untrusted
     * @param int $device_id Device fingerprint ID
     * @return bool Success
     */
    public static function removeTrustedDevice($device_id) {
        $sql = "UPDATE device_fingerprints SET is_trusted = 0 WHERE id = ?";
        $db = Database::getInstance();
        return $db->execute($sql, [$device_id]);
    }
}
?>
