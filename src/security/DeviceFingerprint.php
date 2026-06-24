<?php
/**
 * Device Fingerprinting for Enhanced Security
 */

class DeviceFingerprint {
    
    /**
     * Generate a device fingerprint based on browser and system characteristics
     * @return string Device fingerprint hash
     */
    public static function generate() {
        $fingerprint_data = [
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
            'accept_language' => $_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? '',
            'accept_encoding' => $_SERVER['HTTP_ACCEPT_ENCODING'] ?? '',
            'ip_address' => self::getClientIP(),
            'browser' => self::getBrowserInfo(),
            'os' => self::getOSInfo(),
            'screen_resolution' => $_POST['screen_resolution'] ?? 'unknown',
            'timezone' => $_POST['timezone'] ?? date_default_timezone_get(),
            'timestamp' => time()
        ];

        return hash('sha256', json_encode($fingerprint_data));
    }

    /**
     * Get device fingerprint details
     * @return array Device information
     */
    public static function getDeviceInfo() {
        return [
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
            'accept_language' => $_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? '',
            'ip_address' => self::getClientIP(),
            'browser' => self::getBrowserInfo(),
            'os' => self::getOSInfo(),
            'screen_resolution' => $_POST['screen_resolution'] ?? 'unknown',
            'timezone' => $_POST['timezone'] ?? date_default_timezone_get()
        ];
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
     * Store device fingerprint in database
     * @param int $user_id User ID
     * @param bool $is_trusted Mark as trusted device
     * @return int Device fingerprint ID
     */
    public static function store($user_id, $is_trusted = false) {
        $db = Database::getInstance()->getConnection();
        $fingerprint_hash = self::generate();
        $device_info = json_encode(self::getDeviceInfo());
        $ip_address = self::getClientIP();
        $browser_info = self::getBrowserInfo();

        $sql = "INSERT INTO device_fingerprints 
                (user_id, fingerprint_hash, device_info, ip_address, browser_info, is_trusted) 
                VALUES (?, ?, ?, ?, ?, ?)";
        
        $stmt = $db->prepare($sql);
        $stmt->bind_param('isssis', $user_id, $fingerprint_hash, $device_info, $ip_address, $browser_info, $is_trusted);
        
        if ($stmt->execute()) {
            return $db->insert_id;
        }
        return 0;
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
