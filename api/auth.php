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

try {
    switch ($action) {
        case 'register':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            echo json_encode(Auth::register($_POST));
            break;

        case 'login':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            $totp = $_POST['totp_code'] ?? null;
            echo json_encode(Auth::login($_POST['email'] ?? '', $_POST['password'] ?? '', $totp));
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

            if (empty($_POST['totp_code'])) {
                throw new Exception('TOTP code required');
            }

            $secret = $_SESSION['temp_mfa_secret'] ?? null;
            if (!$secret) {
                throw new Exception('No pending MFA setup');
            }

            if (!MFA::verifyTOTP($secret, $_POST['totp_code'])) {
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

            if (empty($_POST['device_id'])) {
                throw new Exception('Device ID required');
            }

            DeviceFingerprint::removeTrustedDevice($_POST['device_id']);

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
