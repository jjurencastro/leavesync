<?php
/**
 * API - Department Manager (Dean) Functions
 * Lets a manager approve/reject pending user accounts within their own department only.
 */

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../src/database/Database.php';
require_once __DIR__ . '/../src/auth/Auth.php';
require_once __DIR__ . '/../src/auth/DeviceChangeRequest.php';
require_once __DIR__ . '/../src/security/DeviceFingerprint.php';

header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

$user = Auth::getCurrentUser();
if (!$user || $user['role'] !== 'manager') {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

$db = Database::getInstance();

try {
    switch ($action) {
        case 'pending_users':
            echo json_encode(getPendingDepartmentUsers($user));
            break;

        case 'approve_user':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(approveDepartmentUser($_GET['id'] ?? null, $user));
            break;

        case 'reject_user':
            if ($method !== 'DELETE') throw new Exception('Method not allowed');
            echo json_encode(rejectDepartmentUser($_GET['id'] ?? null, $user));
        case 'device_requests':
            echo json_encode(getSupervisorDeviceRequests($user));
            break;

        case 'approve_device_request':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(resolveSupervisorDeviceRequest($_GET['id'] ?? null, 'approved', $user));
            break;

        case 'reject_device_request':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(resolveSupervisorDeviceRequest($_GET['id'] ?? null, 'rejected', $user));
            break;

            break;

        default:
            throw new Exception('Invalid action');
    }
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}

function getPendingDepartmentUsers($user) {
    global $db;

    $users = $db->getResults(
        "SELECT id, username, email, full_name, department, position, is_active, password_set, created_at
         FROM users
         WHERE department = ? AND id <> ? AND is_active = 0 AND password_set = 1
         ORDER BY created_at DESC",
        [$user['department'], $user['id']]
    );

    return ['success' => true, 'data' => $users];
}

function assertOwnDepartmentUser($id, $user) {
    global $db;

    if (!$id) {
        throw new Exception('User ID required');
    }

    $target = $db->getRow("SELECT id, department FROM users WHERE id = ?", [$id]);
    if (!$target || $target['department'] !== $user['department']) {
        throw new Exception('User not found in your department');
    }

    return $target;
}

function approveDepartmentUser($id, $user) {
    global $db;

    assertOwnDepartmentUser($id, $user);


/**
 * Device-change requests from this manager's Tier 1 (employee) direct reports only.
 */
function getSupervisorDeviceRequests($user) {
    $requests = DeviceChangeRequest::getPendingForSupervisor($user['id']);

    foreach ($requests as &$request) {
        $info = json_decode($request['device_info'], true) ?: [];
        $request['changes'] = DeviceFingerprint::diffAgainstTrusted($request['user_id'], $info);
    }

    return ['success' => true, 'data' => $requests];
}

function resolveSupervisorDeviceRequest($id, $status, $user) {
    global $db;

    if (!$id) throw new Exception('Request ID required');

    // Confirm this pending request actually belongs to one of this manager's direct reports
    $request = $db->getRow(
        "SELECT dcr.id FROM device_change_requests dcr
         JOIN users u ON dcr.user_id = u.id
         WHERE dcr.id = ? AND dcr.status = 'pending' AND u.supervisor_id = ? AND u.role = 'employee'",
        [$id, $user['id']]
    );
    if (!$request) throw new Exception('Pending device request not found');

    return DeviceChangeRequest::resolve($id, $status, $user['id']);
}
    $db->execute("UPDATE users SET is_active = 1 WHERE id = ?", [$id]);
    Auth::auditLog($user['id'], 'approve_user', 'user', $id);

    return ['success' => true, 'message' => 'User approved'];
}

function rejectDepartmentUser($id, $user) {
    global $db;

    assertOwnDepartmentUser($id, $user);

    $db->execute("DELETE FROM users WHERE id = ?", [$id]);
    Auth::auditLog($user['id'], 'reject_user', 'user', $id);

    return ['success' => true, 'message' => 'User rejected'];
}
