<?php
/**
 * Authentication Handler
 */

require_once __DIR__ . '/../security/DigitalSignature.php';
require_once __DIR__ . '/../security/DeviceFingerprint.php';
require_once __DIR__ . '/MFA.php';

class Auth {

    private static $current_user = null;

    /**
     * Check whether an email address belongs to the allowed institutional domain
     * @param string $email
     * @return bool
     */
    public static function isAllowedEmailDomain($email) {
        if (empty(ALLOWED_EMAIL_DOMAIN)) {
            return true;
        }
        $domain = strtolower(substr(strrchr($email, '@'), 1));
        return $domain === strtolower(ALLOWED_EMAIL_DOMAIN);
    }

    public static function buildGoogleAuthUrl($redirectUri) {
        $clientId = getenv('GOOGLE_CLIENT_ID') ?: ($GLOBALS['env']['GOOGLE_CLIENT_ID'] ?? '');
        if (empty($clientId)) {
            throw new Exception('Google OAuth is not configured. Set GOOGLE_CLIENT_ID in your environment.');
        }

        $scope = 'openid email profile';
        $params = [
            'client_id' => $clientId,
            'redirect_uri' => $redirectUri,
            'response_type' => 'code',
            'scope' => $scope,
            'access_type' => 'offline',
            'prompt' => 'select_account'
        ];

        return 'https://accounts.google.com/o/oauth2/v2/auth?' . http_build_query($params);
    }

    public static function handleGoogleCallback($code, $redirectUri) {
        $clientId = getenv('GOOGLE_CLIENT_ID') ?: ($GLOBALS['env']['GOOGLE_CLIENT_ID'] ?? '');
        $clientSecret = getenv('GOOGLE_CLIENT_SECRET') ?: ($GLOBALS['env']['GOOGLE_CLIENT_SECRET'] ?? '');

        if (empty($clientId) || empty($clientSecret)) {
            throw new Exception('Google OAuth is not configured');
        }

        $tokenUrl = 'https://oauth2.googleapis.com/token';
        $tokenResponse = self::postJson($tokenUrl, [
            'code' => $code,
            'client_id' => $clientId,
            'client_secret' => $clientSecret,
            'redirect_uri' => $redirectUri,
            'grant_type' => 'authorization_code'
        ]);

        if (empty($tokenResponse['access_token'])) {
            throw new Exception('Google OAuth token exchange failed');
        }

        $userinfo = self::getJson('https://www.googleapis.com/oauth2/v3/userinfo', [
            'access_token' => $tokenResponse['access_token']
        ]);

        if (empty($userinfo['email'])) {
            throw new Exception('Google account email was not returned');
        }

        if (!self::isAllowedEmailDomain($userinfo['email'])) {
            throw new Exception('Only @' . ALLOWED_EMAIL_DOMAIN . ' accounts may sign in');
        }

        $db = Database::getInstance();
        $user = $db->getRow("SELECT id, username, email, password_hash, is_active, password_set, role FROM users WHERE email = ?", [$userinfo['email']]);

        if (!$user) {
            // Derive the username from the email's local part (before the @)
            $username = preg_replace('/[^a-z0-9._-]/', '', strtolower(strstr($userinfo['email'], '@', true)));
            if ($username === '') {
                $username = 'user';
            }
            $baseUsername = $username;
            $counter = 1;
            while ($db->getRow("SELECT id FROM users WHERE username = ?", [$username])) {
                $username = $baseUsername . $counter;
                $counter++;
            }

            $password_hash = password_hash(bin2hex(random_bytes(24)), PASSWORD_BCRYPT);
            $key_pair = DigitalSignature::generateKeyPair();
            // New Google sign-ups are pending until an admin approves them
            $db->execute(
                "INSERT INTO users (username, email, password_hash, full_name, department, public_key, is_active, password_set) VALUES (?, ?, ?, ?, ?, ?, 0, 0)",
                [$username, $userinfo['email'], $password_hash, $userinfo['name'] ?? $userinfo['email'], 'General', $key_pair['public_key']]
            );
            $user = $db->getRow("SELECT id, username, email, password_hash, is_active, password_set, role FROM users WHERE email = ?", [$userinfo['email']]);
        }

        $needs_password_setup = empty($user['password_set']);

        // Allow a brand-new account through once so it can set up its password;
        // after that, block sign-in until an admin approves (is_active = 1)
        if (!$user['is_active'] && !$needs_password_setup) {
            throw new Exception('Your account activation is pending administrator approval.');
        }

        // Once a user has a registered trusted device, only that device may sign in
        // (temporarily exempt admins so they can test from anywhere)
        $trustedDevices = DeviceFingerprint::getTrustedDevices($user['id']);
        $googleRequestData = parseRequestPayload();
        if ($user['role'] !== 'admin' && !empty($trustedDevices) && !DeviceFingerprint::verifyTrustedDevice($user['id'], $googleRequestData)) {
            $fingerprintHash = DeviceFingerprint::generateFromData($googleRequestData);
            if (self::hasPendingDeviceChangeRequest($user['id'], $fingerprintHash)) {
                throw new Exception('A device change request has already been submitted and is pending administrator approval.');
            }

            session_start();
            $_SESSION['pending_device_change_user_id'] = $user['id'];
            $_SESSION['pending_device_change_data'] = $googleRequestData;

            return [
                'success' => true,
                'requires_device_confirmation' => true,
                'user_id' => $user['id']
            ];
        }

        $token = self::createSessionForUser($user['id'], false, $user['role']);

        self::auditLog($user['id'], 'login_success_google', 'user', $user['id']);

        return [
            'success' => true,
            'message' => 'Google login successful',
            'token' => $token,
            'user_id' => $user['id'],
            'needs_password_setup' => $needs_password_setup
        ];
    }

    private static function postJson($url, array $data) {
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        $response = curl_exec($ch);
        curl_close($ch);
        return json_decode($response, true) ?: [];
    }

    private static function getJson($url, array $params = []) {
        $fullUrl = $url . (strpos($url, '?') === false ? '?' : '&') . http_build_query($params);
        $ch = curl_init($fullUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        $response = curl_exec($ch);
        curl_close($ch);
        return json_decode($response, true) ?: [];
    }

    /**
     * Create the auth session/cookie for a user who has completed all login checks.
     * @param string $role Optional role; admins are exempt from the single-trusted-device rule for testing
     * @return string The plaintext session token
     */
    private static function createSessionForUser($user_id, $setNativeSession = false, $role = null) {
        $db = Database::getInstance();
        $device_id = DeviceFingerprint::store($user_id, true, parseRequestPayload(), $role !== 'admin');
        $token = bin2hex(random_bytes(32));
        $token_hash = hash('sha256', $token);
        $expires_at = date('Y-m-d H:i:s', time() + SESSION_LIFETIME);

        $db->execute(
            "INSERT INTO sessions (user_id, token_hash, device_id, ip_address, expires_at) VALUES (?, ?, ?, ?, ?)",
            [$user_id, $token_hash, $device_id, DeviceFingerprint::getDeviceInfo()['ip_address'], $expires_at]
        );

        setcookie('auth_token', $token, [
            'expires' => time() + SESSION_LIFETIME,
            'path' => '/',
            'domain' => parse_url(APP_URL, PHP_URL_HOST),
            'secure' => SESSION_SECURE,
            'httponly' => SESSION_HTTPONLY,
            'samesite' => 'Strict'
        ]);

        if ($setNativeSession) {
            $_SESSION['auth_token'] = $token;
            $_SESSION['user_id'] = $user_id;
        }

        return $token;
    }

    /**
     * Whether the user already has a pending device-change request for this
     * exact device fingerprint, so callers can avoid creating duplicates.
     */
    private static function hasPendingDeviceChangeRequest($user_id, $fingerprint_hash) {
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
    private static function createDeviceChangeRequest($user, array $data) {
        $db = Database::getInstance();
        $fingerprint_hash = DeviceFingerprint::generateFromData($data);
        $info = DeviceFingerprint::getDeviceInfo($data);

        if (self::hasPendingDeviceChangeRequest($user['id'], $fingerprint_hash)) {
            return; // Already awaiting admin review, don't create a duplicate
        }

        $db->execute(
            "INSERT INTO device_change_requests (user_id, fingerprint_hash, device_info, ip_address, browser_info) VALUES (?, ?, ?, ?, ?)",
            [$user['id'], $fingerprint_hash, json_encode($info), $info['ip_address'], $info['browser']]
        );

        self::auditLog($user['id'], 'device_change_requested', 'user', $user['id']);
    }

    /**
     * Get the details of a pending Google-login device change awaiting the
     * user's confirmation (stashed in the native PHP session by handleGoogleCallback).
     */
    public static function getPendingDeviceChangeInfo() {
        session_start();
        $user_id = $_SESSION['pending_device_change_user_id'] ?? null;

        if (!$user_id) {
            return ['success' => false, 'message' => 'No pending device change request.'];
        }

        $data = $_SESSION['pending_device_change_data'] ?? [];
        $changes = DeviceFingerprint::diffAgainstTrusted($user_id, DeviceFingerprint::getDeviceInfo($data));

        return ['success' => true, 'changes' => $changes];
    }

    /**
     * User confirmed they want to request approval for the pending Google-login device change.
     */
    public static function confirmPendingDeviceChange() {
        session_start();
        $user_id = $_SESSION['pending_device_change_user_id'] ?? null;

        if (!$user_id) {
            return ['success' => false, 'message' => 'No pending device change request.'];
        }

        $data = $_SESSION['pending_device_change_data'] ?? [];
        $user = Database::getInstance()->getRow("SELECT id, username, email FROM users WHERE id = ?", [$user_id]);

        self::createDeviceChangeRequest($user, $data);
        unset($_SESSION['pending_device_change_user_id'], $_SESSION['pending_device_change_data']);

        return ['success' => true, 'message' => 'Device change request submitted for administrator approval.'];
    }

    /**
     * User declined to request approval for the pending Google-login device change.
     */
    public static function cancelPendingDeviceChange() {
        session_start();
        unset($_SESSION['pending_device_change_user_id'], $_SESSION['pending_device_change_data']);
        return ['success' => true];
    }

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
            self::initializeLeaveBalances($user_id);

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

            // Find user
            $user = $db->getRow(
                "SELECT id, username, email, password_hash, is_active, role FROM users WHERE username = ?",
                [$username]
            );

            if (!$user) {
                self::auditLog(null, 'login_failed', 'user', null, ['username' => $username]);
                return ['success' => false, 'message' => 'Invalid credentials'];
            }

            if (!$user['is_active']) {
                return ['success' => false, 'message' => 'Your account activation is pending administrator approval.'];
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

            // Once a user has a registered trusted device, only that device may log in
            // (temporarily exempt admins so they can test from anywhere)
            $requestData = parseRequestPayload();
            $trustedDevices = DeviceFingerprint::getTrustedDevices($user['id']);
            $isKnownDevice = $user['role'] === 'admin'
                || empty($trustedDevices)
                || DeviceFingerprint::verifyTrustedDevice($user['id'], $requestData);

            if (!$isKnownDevice) {
                $fingerprintHash = DeviceFingerprint::generateFromData($requestData);
                if (self::hasPendingDeviceChangeRequest($user['id'], $fingerprintHash)) {
                    return [
                        'success' => false,
                        'message' => 'A device change request has already been submitted and is pending administrator approval.'
                    ];
                }

                if (!$confirm_device_change) {
                    $changes = DeviceFingerprint::diffAgainstTrusted($user['id'], DeviceFingerprint::getDeviceInfo($requestData));
                    return [
                        'success' => false,
                        'requires_device_confirmation' => true,
                        'user_id' => $user['id'],
                        'changes' => $changes,
                        'message' => 'We noticed a change in your device, browser, or network.'
                    ];
                }

                self::createDeviceChangeRequest($user, $requestData);
                self::auditLog($user['id'], 'login_failed_untrusted_device', 'user', $user['id']);
                return [
                    'success' => false,
                    'message' => 'Your device change request has been submitted for administrator approval.'
                ];
            }

            // Create session token
            $token = self::createSessionForUser($user['id'], true, $user['role']);

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
                "SELECT s.*, u.id, u.username, u.email, u.full_name, u.department, u.role, u.device_fingerprint, u.password_set
                 FROM sessions s
                 JOIN users u ON s.user_id = u.id
                 WHERE s.token_hash = ? AND s.expires_at > CURRENT_TIMESTAMP",
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
     * Set the password for the currently authenticated user, activating
     * full username/password login for accounts created via Google sign-in.
     * @param int $user_id
     * @param string $password
     * @return array ['success' => bool, 'message' => string]
     */
    public static function setPassword($user_id, $password) {
        if (empty($password) || strlen($password) < 8) {
            return ['success' => false, 'message' => 'Password must be at least 8 characters'];
        }

        $db = Database::getInstance();
        $password_hash = password_hash($password, PASSWORD_BCRYPT);
        $db->execute(
            "UPDATE users SET password_hash = ?, password_set = 1 WHERE id = ?",
            [$password_hash, $user_id]
        );

        self::auditLog($user_id, 'password_set', 'user', $user_id);

        return ['success' => true, 'message' => 'Password set successfully'];
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
    private static function initializeLeaveBalances($user_id) {
        try {
            $db = Database::getInstance();
            $leaveTypes = $db->getResults('SELECT id, days_per_year FROM leave_types');

            foreach ($leaveTypes as $leaveType) {
                $existing = $db->getRow(
                    'SELECT id FROM leave_balances WHERE user_id = ? AND leave_type_id = ?',
                    [$user_id, $leaveType['id']]
                );

                if ($existing) {
                    continue;
                }

                $db->execute(
                    'INSERT INTO leave_balances (user_id, leave_type_id, total_days, used_days, pending_days, balance, fiscal_year) VALUES (?, ?, ?, 0, 0, ?, ?)',
                    [$user_id, $leaveType['id'], $leaveType['days_per_year'], $leaveType['days_per_year'], date('Y')]
                );
            }
        } catch (Exception $e) {
            error_log('Leave balance initialization error: ' . $e->getMessage());
        }
    }

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
        } elseif (!self::isAllowedEmailDomain($data['email'])) {
            $errors[] = 'Email must be a @' . ALLOWED_EMAIL_DOMAIN . ' address';
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
