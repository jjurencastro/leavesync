<?php
/**
 * Username/password login, session/cookie lifecycle, and current-user lookup
 */

require_once __DIR__ . '/../database/Database.php';
require_once __DIR__ . '/../security/DeviceFingerprint.php';
require_once __DIR__ . '/MFA.php';
require_once __DIR__ . '/DeviceChangeRequest.php';
require_once __DIR__ . '/AuditLogger.php';

class AuthSession {

    private static $current_user = null;

    /**
     * Create the auth session/cookie for a user who has completed all login checks.
     * @param string $role Optional role; admins are exempt from the single-trusted-device rule for testing
     * @return string The plaintext session token
     */
    public static function createSessionForUser($user_id, $setNativeSession = false, $role = null) {
        $db = Database::getInstance();
        $device_id = DeviceFingerprint::store($user_id, true, parseRequestPayload(), $role !== 'admin');
        $token = bin2hex(random_bytes(32));
        $token_hash = hash('sha256', $token);
        $expires_at = date('Y-m-d H:i:s', time() + AUTH_SESSION_LIFETIME);

        $db->execute(
            "INSERT INTO sessions (user_id, token_hash, device_id, ip_address, expires_at) VALUES (?, ?, ?, ?, ?)",
            [$user_id, $token_hash, $device_id, DeviceFingerprint::getDeviceInfo()['ip_address'], $expires_at]
        );

        setcookie('auth_token', $token, [
            'expires' => time() + AUTH_SESSION_LIFETIME,
            'path' => '/',
            'domain' => parse_url(APP_URL, PHP_URL_HOST),
            'secure' => SESSION_SECURE,
            'httponly' => SESSION_HTTPONLY,
            // Lax (not Strict) so the cookie survives the top-level redirect Google sends us back through after OAuth
            'samesite' => 'Lax'
        ]);

        if ($setNativeSession) {
            $_SESSION['auth_token'] = $token;
            $_SESSION['user_id'] = $user_id;
        }

        return $token;
    }

    /**
     * Login user
     * @param string $username Username
     * @param string $password User password
     * @param string $totp_code Optional TOTP code for MFA
     * @param bool $confirm_device_change Whether the user confirmed submitting a device change request
     * @return array ['success' => bool, 'message' => string, 'requires_mfa' => bool, 'token' => string]
     */
    public static function login($username, $password, $totp_code = null, $confirm_device_change = false) {
        try {
            session_start();
            $db = Database::getInstance();

            $user = $db->getRow(
                "SELECT id, username, email, password_hash, is_active, role FROM users WHERE username = ?",
                [$username]
            );

            if (!$user) {
                AuditLogger::log(null, 'login_failed', 'user', null, ['username' => $username]);
                return ['success' => false, 'message' => 'Invalid credentials'];
            }

            if (!$user['is_active']) {
                return ['success' => false, 'message' => 'Your account activation is pending administrator approval.'];
            }

            if (!password_verify($password, $user['password_hash'])) {
                AuditLogger::log($user['id'], 'login_failed', 'user', $user['id']);
                return ['success' => false, 'message' => 'Invalid credentials'];
            }

            if (MFA_ENABLED && MFA::isMFAEnabled($user['id'])) {
                if ($totp_code === null) {
                    return [
                        'success' => false,
                        'message' => 'MFA required',
                        'requires_mfa' => true,
                        'user_id' => $user['id']
                    ];
                }

                $secret = MFA::getSecret($user['id']);
                if (!MFA::verifyTOTP($secret, $totp_code)) {
                    if (!MFA::verifyBackupCode($user['id'], $totp_code)) {
                        AuditLogger::log($user['id'], 'login_failed_mfa', 'user', $user['id']);
                        return ['success' => false, 'message' => 'Invalid MFA code'];
                    }
                }
            }

            // Once a user has a registered trusted device, only that device may log in
            // (temporarily exempt admins so they can test from anywhere)
            $requestData = parseRequestPayload();
            $trustedDevices = DeviceFingerprint::getTrustedDevices($user['id']);
            $isKnownDevice = $user['role'] === 'admin'
                || empty($trustedDevices)
                || DeviceFingerprint::verifyTrustedDevice($user['id'], $requestData);

            if (!$isKnownDevice) {
                $fingerprintHash = DeviceFingerprint::generateFromData($requestData);
                if (DeviceChangeRequest::hasPending($user['id'], $fingerprintHash)) {
                    return [
                        'success' => false,
                        'message' => 'A device change request has already been submitted and is pending administrator approval.'
                    ];
                }

                if (!$confirm_device_change) {
                    $changes = DeviceFingerprint::diffAgainstTrusted($user['id'], DeviceFingerprint::getDeviceInfo($requestData), true);
                    return [
                        'success' => false,
                        'requires_device_confirmation' => true,
                        'user_id' => $user['id'],
                        'changes' => $changes,
                        'message' => 'We noticed a change in your device, browser, or network.'
                    ];
                }

                DeviceChangeRequest::create($user, $requestData);
                AuditLogger::log($user['id'], 'login_failed_untrusted_device', 'user', $user['id']);
                return [
                    'success' => false,
                    'message' => 'Your device change request has been submitted for administrator approval.'
                ];
            }

            $token = self::createSessionForUser($user['id'], true, $user['role']);
            AuditLogger::log($user['id'], 'login_success', 'user', $user['id']);

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
            session_start();
            if (!isset($_COOKIE['auth_token']) && empty($_SESSION['auth_token'])) {
                return false;
            }

            $token = $_COOKIE['auth_token'] ?? $_SESSION['auth_token'] ?? '';
            $token_hash = hash('sha256', $token);

            $db = Database::getInstance();
            $db->execute("DELETE FROM sessions WHERE token_hash = ?", [$token_hash]);

            setcookie('auth_token', '', [
                'expires' => time() - 3600,
                'path' => '/',
                'secure' => SESSION_SECURE,
                'httponly' => SESSION_HTTPONLY
            ]);
            unset($_SESSION['auth_token']);
            unset($_SESSION['user_id']);
            session_destroy();

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

            session_start();

            if (!isset($_COOKIE['auth_token']) && empty($_SESSION['auth_token'])) {
                return null;
            }

            $token = $_COOKIE['auth_token'] ?? $_SESSION['auth_token'] ?? '';
            $token_hash = hash('sha256', $token);

            $db = Database::getInstance();
            $session = $db->getRow(
                "SELECT s.*, u.id, u.username, u.email, u.full_name, u.department, u.position, u.gender, u.supervisor_id, u.role, u.device_fingerprint, u.password_set
                 FROM sessions s
                 JOIN users u ON s.user_id = u.id
                 WHERE s.token_hash = ? AND s.expires_at > CURRENT_TIMESTAMP",
                [$token_hash]
            );

            if (!$session) {
                return null;
            }

            // Continuously verify the device/network hasn't changed mid-session
            // (e.g. switching Wi-Fi networks, or the device being replaced via an
            // approved device-change request) instead of only checking at login.
            if ($session['role'] !== 'admin' && !DeviceFingerprint::verifyTrustedDevice($session['user_id'], parseRequestPayload())) {
                $db->execute("DELETE FROM sessions WHERE token_hash = ?", [$token_hash]);
                return null;
            }

            // Sliding expiration: renew the session/cookie while the user is
            // actively using the app, instead of forcing logout after a fixed
            // window even during continuous activity.
            $new_expires_at = date('Y-m-d H:i:s', time() + AUTH_SESSION_LIFETIME);
            $db->execute("UPDATE sessions SET expires_at = ? WHERE token_hash = ?", [$new_expires_at, $token_hash]);
            if (isset($_COOKIE['auth_token'])) {
                setcookie('auth_token', $token, [
                    'expires' => time() + AUTH_SESSION_LIFETIME,
                    'path' => '/',
                    'domain' => parse_url(APP_URL, PHP_URL_HOST),
                    'secure' => SESSION_SECURE,
                    'httponly' => SESSION_HTTPONLY,
                    'samesite' => 'Lax'
                ]);
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
}
