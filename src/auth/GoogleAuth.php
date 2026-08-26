<?php
/**
 * Google OAuth sign-in
 */

require_once __DIR__ . '/../database/Database.php';
require_once __DIR__ . '/../security/DigitalSignature.php';
require_once __DIR__ . '/../security/DeviceFingerprint.php';
require_once __DIR__ . '/AuthSession.php';
require_once __DIR__ . '/DeviceChangeRequest.php';
require_once __DIR__ . '/UserRegistration.php';
require_once __DIR__ . '/AuditLogger.php';

class GoogleAuth {

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

    public static function buildAuthUrl($redirectUri) {
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

    public static function handleCallback($code, $redirectUri) {
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
            $registrationId = UserRegistration::reserveNextUserId();
            $db->execute(
                "INSERT INTO users (id, username, email, password_hash, full_name, department, public_key, is_active, password_set) VALUES (?, ?, ?, ?, ?, ?, ?, 0, 0)",
                [$registrationId, $username, $userinfo['email'], $password_hash, $userinfo['name'] ?? $userinfo['email'], 'General', $key_pair['public_key']]
            );
            UserRegistration::initializeLeaveBalances($registrationId);
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
            if (DeviceChangeRequest::hasPending($user['id'], $fingerprintHash)) {
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

        $token = AuthSession::createSessionForUser($user['id'], false, $user['role']);

        AuditLogger::log($user['id'], 'login_success_google', 'user', $user['id']);

        return [
            'success' => true,
            'message' => 'Google login successful',
            'token' => $token,
            'user_id' => $user['id'],
            'role' => $user['role'],
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
}
