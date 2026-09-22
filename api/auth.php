<?php
/**
 * API - Authentication
 */

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../src/database/Database.php';
require_once __DIR__ . '/../src/auth/Auth.php';
require_once __DIR__ . '/../src/auth/MFA.php';
require_once __DIR__ . '/../src/security/DeviceFingerprint.php';
require_once __DIR__ . '/../src/leave/EmployeeNotifications.php';
require_once __DIR__ . '/../src/leave/EmployeeProfile.php';

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
            if (!empty($result['needs_password_setup'])) {
                $destination = '/activate';
            } else {
                $roleLandingPages = ['admin' => '/admin', 'hr' => '/hr'];
                $destination = $roleLandingPages[$result['role'] ?? null] ?? '/dashboard';
            }
            header('Location: ' . rtrim(APP_URL, '/') . $destination);
            exit;

        case 'profile_picture':
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }

            $user = Auth::getCurrentUser();
            $pictureUrl = $user['profile_picture_url'] ?? '';
            $pictureHost = strtolower(parse_url($pictureUrl, PHP_URL_HOST) ?: '');
            $isGoogleImage = $pictureHost === 'googleusercontent.com'
                || substr($pictureHost, -strlen('.googleusercontent.com')) === '.googleusercontent.com';

            if (!filter_var($pictureUrl, FILTER_VALIDATE_URL)
                || parse_url($pictureUrl, PHP_URL_SCHEME) !== 'https'
                || !$isGoogleImage) {
                http_response_code(404);
                throw new Exception('Profile picture not found');
            }

            $ch = curl_init($pictureUrl);
            curl_setopt_array($ch, [
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_FOLLOWLOCATION => true,
                CURLOPT_MAXREDIRS => 2,
                CURLOPT_CONNECTTIMEOUT => 5,
                CURLOPT_TIMEOUT => 10,
                CURLOPT_SSL_VERIFYPEER => true,
                CURLOPT_USERAGENT => 'LeaveSync profile picture proxy'
            ]);
            $imageData = curl_exec($ch);
            $statusCode = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $contentType = (string) curl_getinfo($ch, CURLINFO_CONTENT_TYPE);
            curl_close($ch);

            if ($imageData === false || $statusCode < 200 || $statusCode >= 300
                || strpos($contentType, 'image/') !== 0) {
                http_response_code(404);
                throw new Exception('Profile picture not available');
            }

            header('Content-Type: ' . explode(';', $contentType)[0]);
            header('Cache-Control: private, max-age=3600');
            echo $imageData;
            break;

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

        case 'cancel_activation':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }
            $user = Auth::getCurrentUser();
            echo json_encode(Auth::cancelActivation($user['id']));
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

        case 'update_profile':
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }
            $user = Auth::getCurrentUser();

            $updates = EmployeeProfile::sanitizeProfileUpdate($data);
            if (empty($updates)) {
                throw new Exception('No valid profile fields provided');
            }

            foreach ($updates as $field => $value) {
                if (!EmployeeProfile::canEditProfile($user, $field)) {
                    throw new Exception('This field cannot be edited in your profile');
                }
                if ($field === 'full_name' && $value === '') {
                    throw new Exception('Full name is required');
                }
                if ($field === 'department' && $value === '') {
                    throw new Exception('Department is required');
                }
                if ($field === 'position' && $value === '') {
                    throw new Exception('Position is required');
                }
            }

            $db = Database::getInstance();
            $placeholders = [];
            $values = [];
            foreach ($updates as $field => $value) {
                $placeholders[] = "$field = ?";
                $values[] = $value;
            }
            $values[] = $user['id'];

            $db->execute(
                "UPDATE users SET " . implode(', ', $placeholders) . " WHERE id = ?",
                $values
            );

            Auth::auditLog($user['id'], 'update_employee_profile', 'user', $user['id']);

            echo json_encode(['success' => true, 'message' => 'Profile updated successfully']);
            break;

        case 'notifications':
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }

            $user = Auth::getCurrentUser();
            $db = Database::getInstance();
            $rows = $db->getResults(
                "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 20",
                [$user['id']]
            );

            echo json_encode([
                'success' => true,
                'data' => array_map([EmployeeNotifications::class, 'formatNotification'], $rows),
                'summary' => EmployeeNotifications::summarize($rows),
            ]);
            break;

        case 'mark_notification_read':
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }

            if (empty($data['id'])) {
                throw new Exception('Notification ID required');
            }

            $user = Auth::getCurrentUser();
            $db = Database::getInstance();
            $db->execute(
                "UPDATE notifications SET is_read = 1, read_at = NOW() WHERE user_id = ? AND id = ?",
                [$user['id'], $data['id']]
            );

            echo json_encode(['success' => true, 'message' => 'Notification marked as read']);
            break;

        case 'mfa_status':
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }

            $user = Auth::getCurrentUser();
            echo json_encode([
                'success' => true,
                'data' => ['enabled' => MFA::isMFAEnabled($user['id'])]
            ]);
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
