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
require_once __DIR__ . '/../src/leave/ApprovalQueue.php';
require_once __DIR__ . '/../src/leave/EmployeeProfile.php';
require_once __DIR__ . '/../src/mail/Mailer.php';

header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';
$data = parseRequestPayload();

try {
    // TEMP DIAGNOSTIC - remove after debugging
    if ($action === 'mail_debug') {
        echo json_encode([
            'MAIL_TRANSPORT' => MAIL_TRANSPORT,
            'BREVO_API_KEY_set' => BREVO_API_KEY !== '',
            'BREVO_API_KEY_prefix' => BREVO_API_KEY !== '' ? substr(BREVO_API_KEY, 0, 10) . '...' : '(empty)',
            'MAIL_FROM' => MAIL_FROM,
            'getenv_MAIL_TRANSPORT' => getenv('MAIL_TRANSPORT'),
            'getenv_BREVO_API_KEY' => getenv('BREVO_API_KEY') !== false ? 'set' : 'NOT SET',
            'isConfigured' => Mailer::isConfigured(),
        ]);
        exit;
    }

    // TEMP DIAGNOSTIC - actually attempt a Brevo send and return the raw result
    if ($action === 'mail_test') {
        $to = $data['to'] ?? ($_GET['to'] ?? '');
        echo json_encode(Mailer::debugBrevo($to));
        exit;
    }

    switch ($action) {
        case 'login':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            $totp = $data['totp_code'] ?? null;
            $confirmDeviceChange = !empty($data['confirm_device_change']);
            echo json_encode(Auth::login($data['username'] ?? '', $data['password'] ?? '', $totp, $confirmDeviceChange));
            break;

        case 'forgot_password':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            echo json_encode(Auth::requestPasswordReset($data['username'] ?? ''));
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

        case 'profile_details':
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }
            $user = Auth::getCurrentUser();
            $db = Database::getInstance();
            EmployeeProfile::ensureDetailsTable($db);
            $row = $db->getRow("SELECT * FROM employee_profile_details WHERE user_id = ?", [$user['id']]);
            $details = [];
            foreach (array_keys(EmployeeProfile::DETAIL_FIELDS) as $field) {
                $details[$field] = $row[$field] ?? null;
            }
            echo json_encode(['success' => true, 'data' => $details]);
            break;

        case 'update_profile_details':
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }
            $user = Auth::getCurrentUser();

            [$clean, $errors] = EmployeeProfile::sanitizeProfileDetails($data);
            if (!empty($errors)) {
                throw new Exception(implode('. ', $errors));
            }
            if (empty($clean)) {
                throw new Exception('No valid profile fields provided');
            }

            $db = Database::getInstance();
            EmployeeProfile::ensureDetailsTable($db);
            $columns = array_keys($clean);
            $updates = array_map(function ($c) { return "$c = VALUES($c)"; }, $columns);
            $db->execute(
                "INSERT INTO employee_profile_details (user_id, " . implode(', ', $columns) . ") VALUES (?, " . implode(', ', array_fill(0, count($columns), '?')) . ") ON DUPLICATE KEY UPDATE " . implode(', ', $updates),
                array_merge([$user['id']], array_values($clean))
            );

            Auth::auditLog($user['id'], 'update_employee_profile_details', 'user', $user['id']);

            echo json_encode(['success' => true, 'message' => 'Details saved']);
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
            $limit = !empty($_GET['all']) ? 200 : 20;

            // Keep the bell aligned with the sidebar approval badge: an "action needed"
            // alert clears as soon as the request is no longer waiting on this user
            // (they approved/rejected it, or it was resolved/cancelled).
            [$waitingSql, $waitingParams] = ApprovalQueue::waitingOnCondition($user);
            $db->execute(
                "UPDATE notifications n
                 JOIN leave_requests lr ON n.related_entity_id = lr.id
                 JOIN users req ON req.id = lr.user_id
                 SET n.is_read = 1, n.read_at = NOW()
                 WHERE n.user_id = ? AND n.is_read = 0 AND n.related_entity_type = 'leave_request'
                   AND n.title IN ('New Leave Request', 'Approval Reminder')
                   AND NOT {$waitingSql}",
                array_merge([$user['id']], $waitingParams)
            );
            // Informational escalation notices only clear once the request is resolved
            $db->execute(
                "UPDATE notifications n
                 JOIN leave_requests lr ON n.related_entity_id = lr.id
                 SET n.is_read = 1, n.read_at = NOW()
                 WHERE n.user_id = ? AND n.is_read = 0 AND n.related_entity_type = 'leave_request'
                   AND n.title = 'Leave Request Escalated' AND lr.status <> 'pending'",
                [$user['id']]
            );

            $rows = $db->getResults(
                "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT " . $limit,
                [$user['id']]
            );
            $unreadRow = $db->getRow(
                "SELECT COUNT(*) AS unread FROM notifications WHERE user_id = ? AND is_read = 0",
                [$user['id']]
            );

            $summary = EmployeeNotifications::summarize($rows);
            $summary['unread'] = (int) ($unreadRow['unread'] ?? $summary['unread']);
            $deviceRow = $db->getRow(
                "SELECT COUNT(*) AS unread FROM notifications
                 WHERE user_id = ? AND is_read = 0 AND related_entity_type = 'device_change'
                   AND title IN ('New Device Change Request', 'Device Change Request Escalated')",
                [$user['id']]
            );
            $summary['unread_device_requests'] = (int) ($deviceRow['unread'] ?? 0);

            echo json_encode([
                'success' => true,
                'data' => array_map([EmployeeNotifications::class, 'formatNotification'], $rows),
                'summary' => $summary,
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

        case 'mark_all_notifications_read':
            if (!Auth::isAuthenticated()) {
                http_response_code(401);
                throw new Exception('Unauthorized');
            }

            $user = Auth::getCurrentUser();
            $db = Database::getInstance();
            $db->execute(
                "UPDATE notifications SET is_read = 1, read_at = NOW() WHERE user_id = ? AND is_read = 0",
                [$user['id']]
            );

            echo json_encode(['success' => true, 'message' => 'All notifications marked as read']);
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
