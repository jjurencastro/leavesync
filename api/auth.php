<?php
/**
 * API - Authentication
 */

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../src/database/Database.php';
require_once __DIR__ . '/../src/auth/Auth.php';
require_once __DIR__ . '/../src/auth/MFA.php';
require_once __DIR__ . '/../src/security/DeviceFingerprint.php';

header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';
$data = parseRequestPayload();

try {
    switch ($action) {
        case 'login':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            $totp = $data['totp_code'] ?? null;
            $confirmDeviceChange = !empty($data['confirm_device_change']);
            echo json_encode(Auth::login($data['username'] ?? '', $data['password'] ?? '', $totp, $confirmDeviceChange));
            break;

        case 'google_login':
            $redirectUri = ($data['redirect_uri'] ?? '') ?: (currentOrigin() . '/api/auth.php?action=google_callback');
            try {
                echo json_encode(['success' => true, 'url' => Auth::buildGoogleAuthUrl($redirectUri)]);
            } catch (Exception $e) {
                echo json_encode(['success' => false, 'message' => $e->getMessage()]);
            }
            break;

        case 'google_callback':
            if (empty($_GET['code'])) {
                throw new Exception('Google authorization code missing');
            }
            // Must exactly match the redirect_uri used to obtain the auth code
            $redirectUri = currentOrigin() . '/api/auth.php?action=google_callback';
            try {
                $result = Auth::handleGoogleCallback($_GET['code'], $redirectUri);
            } catch (Exception $e) {
                header('Location: ' . rtrim(APP_URL, '/') . '/login?google_error=' . urlencode($e->getMessage()));
                exit;
            }
            if (!empty($result['requires_device_confirmation'])) {
                header('Location: ' . rtrim(APP_URL, '/') . '/confirm-device-change');
                exit;
            }
            if (($result['role'] ?? null) === 'admin') {
                header('Location: ' . rtrim(APP_URL, '/') . '/admin');
                exit;
            }
            $destination = !empty($result['needs_password_setup']) ? '/activate' : '/dashboard';
            header('Location: ' . rtrim(APP_URL, '/') . $destination);
            exit;

        case 'device_change_info':
            echo json_encode(Auth::getPendingDeviceChangeInfo());
            break;

        case 'confirm_device_change':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            echo json_encode(Auth::confirmPendingDeviceChange());
            break;

        case 'cancel_device_change':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            echo json_encode(Auth::cancelPendingDeviceChange());
            break;

        case 'set_password':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }
            $user = Auth::getCurrentUser();
            echo json_encode(Auth::setPassword($user['id'], $data['password'] ?? '', $data));
            break;

        case 'change_password':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }
            $user = Auth::getCurrentUser();
            echo json_encode(Auth::changePassword($user['id'], $data['current_password'] ?? '', $data['new_password'] ?? ''));
            break;

        case 'activation_info':
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }
            $user = Auth::getCurrentUser();
            echo json_encode(Auth::getActivationInfo($user['id']));
            break;

        case 'logout':
            Auth::logout();
            echo json_encode(['success' => true, 'message' => 'Logged out']);
            break;

        case 'profile':
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }
            $user = Auth::getCurrentUser();
            echo json_encode(['success' => true, 'data' => $user]);
            break;

        case 'mfa_setup':
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }
            
            $secret = MFA::generateSecret();
            $user = Auth::getCurrentUser();
            $qr_url = MFA::getQRCodeURL($secret, $user['email']);
            
            $_SESSION['temp_mfa_secret'] = $secret;
            
            echo json_encode([
                'success' => true,
                'secret' => $secret,
                'qr_url' => $qr_url
            ]);
            break;

        case 'mfa_enable':
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }

            if (empty($data['totp_code'])) {
                throw new Exception('TOTP code required');
            }

            $secret = $_SESSION['temp_mfa_secret'] ?? null;
            if (!$secret) {
                throw new Exception('No pending MFA setup');
            }

            if (!MFA::verifyTOTP($secret, $data['totp_code'])) {
                throw new Exception('Invalid TOTP code');
            }

            $user = Auth::getCurrentUser();
            MFA::enableMFA($user['id'], $secret);
            unset($_SESSION['temp_mfa_secret']);

            echo json_encode(['success' => true, 'message' => 'MFA enabled']);
            break;

        case 'mfa_disable':
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }

            $user = Auth::getCurrentUser();
            MFA::disableMFA($user['id']);

            echo json_encode(['success' => true, 'message' => 'MFA disabled']);
            break;

        case 'devices':
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }

            $user = Auth::getCurrentUser();
            $devices = DeviceFingerprint::getTrustedDevices($user['id']);

            echo json_encode(['success' => true, 'data' => $devices]);
            break;

        case 'remove_device':
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }

            if (empty($data['device_id'])) {
                throw new Exception('Device ID required');
            }

            DeviceFingerprint::removeTrustedDevice($data['device_id']);

            echo json_encode(['success' => true, 'message' => 'Device removed']);
            break;

        default:
            throw new Exception('Invalid action');
    }
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>
