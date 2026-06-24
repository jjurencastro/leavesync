<?php
/**
 * Authentication Handler
 */

class Auth {

    private static $current_user = null;

    /**
     * Register new user
     * @param array $data User registration data
     * @return array ['success' => bool, 'message' => string, 'user_id' => int]
     */
    public static function register($data) {
        try {
            // Validate input
            $errors = self::validateRegistration($data);
            if (!empty($errors)) {
                return ['success' => false, 'message' => implode(', ', $errors)];
            }

            $db = Database::getInstance();

            // Check if user already exists
            $existing = $db->getRow(
                "SELECT id FROM users WHERE email = ? OR username = ?",
                [$data['email'], $data['username']]
            );

            if ($existing) {
                return ['success' => false, 'message' => 'Email or username already exists'];
            }

            // Hash password
            $password_hash = password_hash($data['password'], PASSWORD_BCRYPT);

            // Generate RSA key pair for digital signatures
            $key_pair = DigitalSignature::generateKeyPair();

            // Insert user
            $sql = "INSERT INTO users 
                    (username, email, password_hash, full_name, department, public_key) 
                    VALUES (?, ?, ?, ?, ?, ?)";

            $db->execute($sql, [
                $data['username'],
                $data['email'],
                $password_hash,
                $data['full_name'],
                $data['department'] ?? 'General',
                $key_pair['public_key']
            ]);

            $user_id = $db->lastInsertId();

            // Store private key securely (in real environment, use encrypted storage)
            // For now, we're only storing public key in DB

            return [
                'success' => true,
                'message' => 'User registered successfully',
                'user_id' => $user_id
            ];

        } catch (Exception $e) {
            error_log("Registration error: " . $e->getMessage());
            return ['success' => false, 'message' => 'Registration failed'];
        }
    }

    /**
     * Login user
     * @param string $email User email
     * @param string $password User password
     * @param string $totp_code Optional TOTP code for MFA
     * @return array ['success' => bool, 'message' => string, 'requires_mfa' => bool, 'token' => string]
     */
    public static function login($email, $password, $totp_code = null) {
        try {
            $db = Database::getInstance();

            // Find user
            $user = $db->getRow(
                "SELECT id, username, email, password_hash, is_active FROM users WHERE email = ?",
                [$email]
            );

            if (!$user) {
                self::auditLog(null, 'login_failed', 'user', null, ['email' => $email]);
                return ['success' => false, 'message' => 'Invalid credentials'];
            }

            if (!$user['is_active']) {
                return ['success' => false, 'message' => 'User account is inactive'];
            }

            // Verify password
            if (!password_verify($password, $user['password_hash'])) {
                self::auditLog($user['id'], 'login_failed', 'user', $user['id']);
                return ['success' => false, 'message' => 'Invalid credentials'];
            }

            // Check if MFA is enabled
            if (MFA_ENABLED && MFA::isMFAEnabled($user['id'])) {
                if ($totp_code === null) {
                    return [
                        'success' => false,
                        'message' => 'MFA required',
                        'requires_mfa' => true,
                        'user_id' => $user['id']
                    ];
                }

                // Verify TOTP code
                $secret = MFA::getSecret($user['id']);
                if (!MFA::verifyTOTP($secret, $totp_code)) {
                    // Check backup codes
                    if (!MFA::verifyBackupCode($user['id'], $totp_code)) {
                        self::auditLog($user['id'], 'login_failed_mfa', 'user', $user['id']);
                        return ['success' => false, 'message' => 'Invalid MFA code'];
                    }
                }
            }

            // Get or create device fingerprint
            $device_id = DeviceFingerprint::store($user['id']);

            // Create session token
            $token = bin2hex(random_bytes(32));
            $token_hash = hash('sha256', $token);
            $expires_at = date('Y-m-d H:i:s', time() + SESSION_LIFETIME);

            $sql = "INSERT INTO sessions (user_id, token_hash, device_id, ip_address, expires_at) 
                    VALUES (?, ?, ?, ?, ?)";

            $db->execute($sql, [
                $user['id'],
                $token_hash,
                $device_id,
                DeviceFingerprint::getDeviceInfo()['ip_address'],
                $expires_at
            ]);

            // Set session cookie
            setcookie('auth_token', $token, [
                'expires' => time() + SESSION_LIFETIME,
                'path' => '/',
                'domain' => parse_url(APP_URL, PHP_URL_HOST),
                'secure' => SESSION_SECURE,
                'httponly' => SESSION_HTTPONLY,
                'samesite' => 'Strict'
            ]);

            self::auditLog($user['id'], 'login_success', 'user', $user['id']);

            return [
                'success' => true,
                'message' => 'Login successful',
                'token' => $token,
                'user_id' => $user['id']
            ];

        } catch (Exception $e) {
            error_log("Login error: " . $e->getMessage());
            return ['success' => false, 'message' => 'Login failed'];
        }
    }

    /**
     * Logout user
     * @return bool Success
     */
    public static function logout() {
        try {
            if (!isset($_COOKIE['auth_token'])) {
                return false;
            }

            $token = $_COOKIE['auth_token'];
            $token_hash = hash('sha256', $token);

            $db = Database::getInstance();
            $db->execute("DELETE FROM sessions WHERE token_hash = ?", [$token_hash]);

            setcookie('auth_token', '', [
                'expires' => time() - 3600,
                'path' => '/',
                'secure' => SESSION_SECURE,
                'httponly' => SESSION_HTTPONLY
            ]);

            return true;
        } catch (Exception $e) {
            error_log("Logout error: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Verify current user session
     * @return array|null User data or null if not authenticated
     */
    public static function getCurrentUser() {
        try {
            if (self::$current_user !== null) {
                return self::$current_user;
            }

            if (!isset($_COOKIE['auth_token'])) {
                return null;
            }

            $token = $_COOKIE['auth_token'];
            $token_hash = hash('sha256', $token);

            $db = Database::getInstance();
            $session = $db->getRow(
                "SELECT s.*, u.id, u.username, u.email, u.full_name, u.department, u.role, u.device_fingerprint 
                 FROM sessions s
                 JOIN users u ON s.user_id = u.id
                 WHERE s.token_hash = ? AND s.expires_at > NOW()",
                [$token_hash]
            );

            if (!$session) {
                return null;
            }

            self::$current_user = $session;
            return $session;

        } catch (Exception $e) {
            error_log("Session verification error: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Check if user is authenticated
     * @return bool Is authenticated
     */
    public static function isAuthenticated() {
        return self::getCurrentUser() !== null;
    }

    /**
     * Check if user has specific role
     * @param string $role Role to check
     * @return bool Has role
     */
    public static function hasRole($role) {
        $user = self::getCurrentUser();
        return $user && $user['role'] === $role;
    }

    /**
     * Log audit event
     * @param int|null $user_id User ID
     * @param string $action Action performed
     * @param string $entity_type Entity type
     * @param int|null $entity_id Entity ID
     * @param array $changes Changes made
     * @return void
     */
    public static function auditLog($user_id, $action, $entity_type, $entity_id = null, $changes = []) {
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

    /**
     * Validate registration data
     * @param array $data Registration data
     * @return array Validation errors
     */
    private static function validateRegistration($data) {
        $errors = [];

        if (empty($data['username']) || strlen($data['username']) < 3) {
            $errors[] = 'Username must be at least 3 characters';
        }

        if (empty($data['email']) || !filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            $errors[] = 'Valid email is required';
        }

        if (empty($data['password']) || strlen($data['password']) < 8) {
            $errors[] = 'Password must be at least 8 characters';
        }

        if (empty($data['full_name'])) {
            $errors[] = 'Full name is required';
        }

        return $errors;
    }
}
?>
