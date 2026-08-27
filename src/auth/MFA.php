<?php
/**
 * Multi-Factor Authentication (MFA) Handler
 * Implements TOTP (Time-based One-Time Password) for 2FA
 */

class MFA {

    /**
     * Generate TOTP secret for user
     * @return string Base32-encoded secret
     */
    public static function generateSecret() {
        $bytes = random_bytes(32);
        return self::base32Encode($bytes);
    }

    /**
     * Get TOTP code for current time
     * @param string $secret Base32-encoded secret
     * @return string 6-digit TOTP code
     */
    public static function getTOTPCode($secret) {
        $time = floor(time() / MFA_WINDOW);
        $decoded = self::base32Decode($secret);
        
        $hash = hash_hmac('sha1', pack('N*', 0, $time), $decoded, true);
        $offset = ord(substr($hash, -1)) & 0x0F;
        $code = unpack('N', substr($hash, $offset, 4))[1] & 0x7FFFFFFF;
        
        return str_pad($code % 1000000, 6, '0', STR_PAD_LEFT);
    }

    /**
     * Verify TOTP code
     * @param string $secret Base32-encoded secret
     * @param string $code 6-digit code to verify
     * @param int $window_size Number of windows to check (default 1, checks past and future)
     * @return bool Is code valid
     */
    public static function verifyTOTP($secret, $code, $window_size = 1) {
        $current_time = floor(time() / MFA_WINDOW);
        
        for ($i = -$window_size; $i <= $window_size; $i++) {
            $time = $current_time + $i;
            $decoded = self::base32Decode($secret);
            
            $hash = hash_hmac('sha1', pack('N*', 0, $time), $decoded, true);
            $offset = ord(substr($hash, -1)) & 0x0F;
            $totp_code = unpack('N', substr($hash, $offset, 4))[1] & 0x7FFFFFFF;
            $totp_code = str_pad($totp_code % 1000000, 6, '0', STR_PAD_LEFT);
            
            if (hash_equals($totp_code, $code)) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * Generate backup codes
     * @param int $count Number of backup codes to generate
     * @return array Array of backup codes
     */
    public static function generateBackupCodes($count = 10) {
        $codes = [];
        for ($i = 0; $i < $count; $i++) {
            $code = strtoupper(substr(bin2hex(random_bytes(4)), 0, 8));
            $codes[] = $code;
        }
        return $codes;
    }

    /**
     * Create QR Code URL for authenticator apps
     * @param string $secret Base32-encoded secret
     * @param string $email User's email
     * @param string $issuer Application name (issuer)
     * @return string QR Code URL
     */
    public static function getQRCodeURL($secret, $email, $issuer = 'LeaveSync') {
        $label = rawurlencode($issuer . ':' . $email);
        $secret_encoded = rawurlencode($secret);
        $issuer_encoded = rawurlencode($issuer);

        return "otpauth://totp/{$label}?secret={$secret_encoded}&issuer={$issuer_encoded}";
    }

    /**
     * Enable MFA for user
     * @param int $user_id User ID
     * @param string $secret TOTP secret
     * @return bool Success
     */
    public static function enableMFA($user_id, $secret) {
        $backup_codes = self::generateBackupCodes();
        $backup_codes_json = json_encode($backup_codes);
        
        $sql = "INSERT INTO mfa_secrets (user_id, secret, backup_codes, is_enabled) 
                VALUES (?, ?, ?, 1) 
                ON DUPLICATE KEY UPDATE 
                secret = ?, backup_codes = ?, is_enabled = 1";
        
        $db = Database::getInstance();
        return $db->execute($sql, [$user_id, $secret, $backup_codes_json, $secret, $backup_codes_json]);
    }

    /**
     * Disable MFA for user
     * @param int $user_id User ID
     * @return bool Success
     */
    public static function disableMFA($user_id) {
        $sql = "UPDATE mfa_secrets SET is_enabled = 0 WHERE user_id = ?";
        $db = Database::getInstance();
        return $db->execute($sql, [$user_id]);
    }

    /**
     * Check if MFA is enabled for user
     * @param int $user_id User ID
     * @return bool Is MFA enabled
     */
    public static function isMFAEnabled($user_id) {
        $sql = "SELECT is_enabled FROM mfa_secrets WHERE user_id = ? AND is_enabled = 1";
        $db = Database::getInstance();
        $result = $db->getRow($sql, [$user_id]);
        return !empty($result);
    }

    /**
     * Get MFA secret for user
     * @param int $user_id User ID
     * @return string|null TOTP secret or null
     */
    public static function getSecret($user_id) {
        $sql = "SELECT secret FROM mfa_secrets WHERE user_id = ? AND is_enabled = 1";
        $db = Database::getInstance();
        $result = $db->getRow($sql, [$user_id]);
        return $result['secret'] ?? null;
    }

    /**
     * Verify backup code
     * @param int $user_id User ID
     * @param string $code Backup code to verify
     * @return bool Is code valid
     */
    public static function verifyBackupCode($user_id, $code) {
        $sql = "SELECT backup_codes FROM mfa_secrets WHERE user_id = ? AND is_enabled = 1";
        $db = Database::getInstance();
        $result = $db->getRow($sql, [$user_id]);
        
        if (!$result) return false;
        
        $backup_codes = json_decode($result['backup_codes'], true);
        $code = strtoupper(trim($code));
        
        if (($key = array_search($code, $backup_codes)) !== false) {
            unset($backup_codes[$key]);
            $updated_codes = json_encode(array_values($backup_codes));
            
            $update_sql = "UPDATE mfa_secrets SET backup_codes = ? WHERE user_id = ?";
            $db->execute($update_sql, [$updated_codes, $user_id]);
            
            return true;
        }
        
        return false;
    }

    /**
     * Base32 encode
     * @param string $data Data to encode
     * @return string Base32-encoded string
     */
    private static function base32Encode($data) {
        $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
        $binary = '';
        
        foreach (str_split($data) as $char) {
            $binary .= str_pad(decbin(ord($char)), 8, '0', STR_PAD_LEFT);
        }
        
        $binary = str_pad($binary, (int)ceil(strlen($binary) / 5) * 5, '0', STR_PAD_RIGHT);
        $result = '';
        
        for ($i = 0; $i < strlen($binary); $i += 5) {
            $result .= $alphabet[bindec(substr($binary, $i, 5))];
        }
        
        return $result;
    }

    /**
     * Base32 decode
     * @param string $data Base32-encoded string
     * @return string Decoded data
     */
    private static function base32Decode($data) {
        $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
        $binary = '';
        
        foreach (str_split(strtoupper($data)) as $char) {
            $pos = strpos($alphabet, $char);
            if ($pos === false) continue;
            $binary .= str_pad(decbin($pos), 5, '0', STR_PAD_LEFT);
        }
        
        $binary = str_pad(substr($binary, 0, (int)strlen($binary) / 8 * 8), (int)(strlen($binary) / 8) * 8, '0', STR_PAD_RIGHT);
        $result = '';
        
        for ($i = 0; $i < strlen($binary); $i += 8) {
            $result .= chr(bindec(substr($binary, $i, 8)));
        }
        
        return $result;
    }
}
?>
