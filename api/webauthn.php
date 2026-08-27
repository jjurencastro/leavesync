<?php
/**
 * API - WebAuthn Passkeys (manager/hr/admin approval credential)
 */

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../src/database/Database.php';
require_once __DIR__ . '/../src/auth/Auth.php';
require_once __DIR__ . '/../src/security/WebAuthnService.php';

header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';
$data = parseRequestPayload();

if (!Auth::isAuthenticated()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

$user = Auth::getCurrentUser();
$db = Database::getInstance();

try {
    switch ($action) {
        case 'register_options':
            echo json_encode(['success' => true, 'options' => WebAuthnService::getRegistrationOptions($user)]);
            break;

        case 'register_verify':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            echo json_encode(WebAuthnService::verifyRegistration($user, $data['response'] ?? [], $data['label'] ?? null));
            break;

        case 'credentials':
            echo json_encode(['success' => true, 'data' => WebAuthnService::listCredentials($user['id'])]);
            break;

        case 'delete_credential':
            if ($method !== 'DELETE') throw new Exception('Method not allowed');
            echo json_encode(WebAuthnService::deleteCredential($_GET['id'] ?? null, $user['id']));
            break;

        case 'approval_challenge':
            $contextType = $_GET['type'] ?? '';
            $contextId = (int) ($_GET['id'] ?? 0);
            if (!in_array($contextType, ['leave_request', 'device_change'], true) || !$contextId) {
                throw new Exception('A valid request type and ID are required');
            }
            assertPendingContext($contextType, $contextId);
            echo json_encode(['success' => true, 'options' => WebAuthnService::getApprovalOptions($user, $contextType, $contextId)]);
            break;

        default:
            throw new Exception('Invalid action');
    }
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}

/**
 * Light existence/pending check before issuing an approval challenge; the actual
 * approve/reject endpoint still performs the full stage/ownership authorization.
 */
function assertPendingContext($contextType, $contextId) {
    global $db;

    if ($contextType === 'leave_request') {
        $row = $db->getRow("SELECT id FROM leave_requests WHERE id = ? AND status = 'pending'", [$contextId]);
    } else {
        $row = $db->getRow("SELECT id FROM device_change_requests WHERE id = ? AND status = 'pending'", [$contextId]);
    }

    if (!$row) {
        throw new Exception('This request is no longer pending');
    }
}
