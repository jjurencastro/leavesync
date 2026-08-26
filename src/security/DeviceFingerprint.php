<?php
/**
 * Device Fingerprinting for Enhanced Security
 */

class DeviceFingerprint {

    /**
     * Generate a device fingerprint based on browser and system characteristics.
     * Only uses fields reliably available from server-side request headers
     * (user agent, browser, OS, IP) so the hash is consistent whether the
     * login came through a direct form POST (with JS-supplied extras) or a
     * Google OAuth redirect (a plain GET with no JS payload at all).
     * @param array $data Optional browser/device data supplied by the client
     * @return string Device fingerprint hash
     */
    public static function generateFromData(array $data = []) {
        $fingerprint_data = self::buildHashData($data);
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
     * Compare a candidate device's info against the user's most recently used
     * trusted device, returning only the fields that actually differ
     * (browser, device/OS, IP address) so it can be shown to the user/admin.
     * @param int $user_id
     * @param array $newInfo Result of getDeviceInfo() for the new attempt
     * @param bool $maskSensitive Mask sensitive fields (e.g. IP address) for display to the
     *   requesting user; admins reviewing the approval always see the unmasked values.
     * @return array e.g. ['browser' => ['label' => 'Browser', 'old' => 'Chrome 120', 'new' => 'Firefox 115']]
     */
    public static function diffAgainstTrusted($user_id, array $newInfo, $maskSensitive = false) {
        $db = Database::getInstance();
        $trusted = $db->getRow(
            "SELECT device_info FROM device_fingerprints WHERE user_id = ? AND is_trusted = 1 ORDER BY last_used DESC LIMIT 1",
            [$user_id]
        );

        if (!$trusted) {
            return [];
        }

        $old = json_decode($trusted['device_info'], true) ?: [];
        $fields = ['browser' => 'Browser', 'device' => 'Device', 'os' => 'Operating System', 'ip_address' => 'IP Address'];
        $changes = [];

        foreach ($fields as $key => $label) {
            $oldValue = $old[$key] ?? 'Unknown';
            $newValue = $newInfo[$key] ?? 'Unknown';
            if ($oldValue !== $newValue) {
                $changes[$key] = ['label' => $label, 'old' => $oldValue, 'new' => $newValue];
            }
        }

        if ($maskSensitive) {
            if (isset($changes['ip_address'])) {
                $changes['ip_address']['old'] = self::maskIp($changes['ip_address']['old']);
                $changes['ip_address']['new'] = self::maskIp($changes['ip_address']['new']);
            }
            foreach (['browser', 'os'] as $key) {
                if (isset($changes[$key])) {
                    $changes[$key]['old'] = self::maskVersion($changes[$key]['old']);
                    $changes[$key]['new'] = self::maskVersion($changes[$key]['new']);
                }
            }
            if (isset($changes['device'])) {
                $changes['device']['old'] = self::maskDevice($changes['device']['old']);
                $changes['device']['new'] = self::maskDevice($changes['device']['new']);
            }
        }

        return $changes;
    }

    /**
     * Partially obscure an IP address for display to non-admin users.
     */
    private static function maskIp($ip) {
        if (empty($ip) || $ip === 'Unknown') {
            return $ip;
        }
        if (strpos($ip, ':') !== false) {
            $parts = explode(':', $ip);
            return implode(':', array_slice($parts, 0, 2)) . ':****';
        }
        $parts = explode('.', $ip);
        if (count($parts) === 4) {
            return $parts[0] . '.' . $parts[1] . '.*.*';
        }
        return '***';
    }

    /**
     * Strip the version/OS-release number from a browser or OS string
     * (e.g. "Chrome 120" -> "Chrome", "macOS 14.2" -> "macOS") so exact
     * version fingerprints aren't exposed to the requesting user.
     */
    private static function maskVersion($value) {
        if (empty($value) || $value === 'Unknown') {
            return $value;
        }
        $masked = trim(preg_replace('/[\d][\d.\s_]*$/', '', $value));
        return $masked !== '' ? $masked : $value;
    }

    /**
     * Generalize a device string to its broad category (e.g. a raw Android
     * model string becomes "Android Device") so the requesting user doesn't
     * see exact hardware identifiers.
     */
    private static function maskDevice($value) {
        $generic = ['iPhone', 'iPad', 'iPod', 'Android Device', 'Windows PC', 'Mac', 'Linux PC', 'Unknown'];
        return in_array($value, $generic, true) ? $value : 'Unknown Device';
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
     * Extract OS information from user agent. Mobile OSes are checked before
     * desktop macOS/Linux, since iOS/Android user agents also contain the
     * substrings "Mac OS X" / "Linux" and would otherwise be misdetected.
     * @return string Operating system
     */
    private static function getOSInfo() {
        $ua = $_SERVER['HTTP_USER_AGENT'] ?? '';

        if (strpos($ua, 'iPhone') !== false || strpos($ua, 'iPad') !== false || strpos($ua, 'iPod') !== false) {
            preg_match('/OS ([\d_]+) like Mac OS X/', $ua, $matches);
            return 'iOS ' . (isset($matches[1]) ? str_replace('_', '.', $matches[1]) : 'unknown');
        } elseif (strpos($ua, 'Android') !== false) {
            preg_match('/Android ([\d.]+)/', $ua, $matches);
            return 'Android ' . ($matches[1] ?? 'unknown');
        } elseif (strpos($ua, 'Windows NT 10.0') !== false) {
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
     * Determine the physical device type/model, separate from the OS
     * (e.g. "iPhone", "iPad", "Android Device", "Windows PC", "Mac", "Linux PC").
     * @return string Device type
     */
    private static function getDeviceType() {
        $ua = $_SERVER['HTTP_USER_AGENT'] ?? '';

        if (strpos($ua, 'iPad') !== false) {
            return 'iPad';
        } elseif (strpos($ua, 'iPhone') !== false) {
            return 'iPhone';
        } elseif (strpos($ua, 'iPod') !== false) {
            return 'iPod';
        } elseif (strpos($ua, 'Android') !== false) {
            return 'Android Device';
        } elseif (strpos($ua, 'Windows') !== false) {
            return 'Windows PC';
        } elseif (strpos($ua, 'Macintosh') !== false) {
            return 'Mac';
        } elseif (strpos($ua, 'Linux') !== false) {
            return 'Linux PC';
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
            'device' => self::getDeviceType(),
            'screen_resolution' => $data['screen_resolution'] ?? $_POST['screen_resolution'] ?? 'unknown',
            'timezone' => $data['timezone'] ?? $_POST['timezone'] ?? date_default_timezone_get(),
            'language' => $data['language'] ?? $_POST['language'] ?? '',
            'platform' => $data['platform'] ?? $_POST['platform'] ?? '',
            'hardware_concurrency' => $data['hardware_concurrency'] ?? $_POST['hardware_concurrency'] ?? 'unknown',
            'device_memory' => $data['device_memory'] ?? $_POST['device_memory'] ?? 'unknown',
        ];
    }

    /**
     * Subset of buildFingerprintData() used specifically for the trust hash:
     * only fields derivable from server-side request headers, so a Google
     * OAuth redirect (no JS payload) and a direct form login (with JS extras)
     * produce the same fingerprint for the same actual browser/device.
     * IP address is deliberately excluded: mobile carriers/networks rotate it
     * mid-session, which would otherwise untrust the device and force logout.
     */
    private static function buildHashData(array $data = []) {
        $full = self::buildFingerprintData($data);
        return [
            'user_agent' => $full['user_agent'],
            'accept_language' => $full['accept_language'],
            'accept_encoding' => $full['accept_encoding'],
            'browser' => $full['browser'],
            'os' => $full['os'],
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
     * @param bool $enforceSingleDevice Revoke trust from the user's other devices (set false to exempt, e.g. admin testing)
     * @return int Device fingerprint ID
     */
    public static function store($user_id, $is_trusted = true, array $data = [], $enforceSingleDevice = true) {
        $db = Database::getInstance();
        $fingerprint_hash = self::generateFromData($data);
        $device_info = json_encode(self::getDeviceInfo($data));
        $ip_address = self::getClientIP();
        $browser_info = self::getBrowserInfo();

        if ($is_trusted && $enforceSingleDevice) {
            self::untrustOtherDevices($user_id, $fingerprint_hash);
        }

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

        self::untrustOtherDevices($user_id, $fingerprint_hash);

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
     * Users may only have one trusted device at a time; revoke trust from
     * every other device on file when a new one is being trusted.
     */
    private static function untrustOtherDevices($user_id, $fingerprint_hash) {
        $db = Database::getInstance();
        $db->execute(
            "UPDATE device_fingerprints SET is_trusted = 0 WHERE user_id = ? AND fingerprint_hash != ? AND is_trusted = 1",
            [$user_id, $fingerprint_hash]
        );
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
