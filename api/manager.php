<?php
/**
 * API - Department Manager (Dean) Functions
 * Lets a manager approve/reject pending user accounts within their own department only.
 */

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../src/database/Database.php';
require_once __DIR__ . '/../src/auth/Auth.php';
require_once __DIR__ . '/../src/auth/DeviceChangeRequest.php';
require_once __DIR__ . '/../src/auth/UserRegistration.php';
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
if (empty($user['password_set']) || empty($user['is_active'])) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Account activation pending']);
    exit;
}

$db = Database::getInstance();

try {
    switch ($action) {
        case 'pending_users':
            echo json_encode(getPendingDepartmentUsers($user));
            break;

        case 'department_positions':
            echo json_encode(['success' => true, 'data' => UserRegistration::getDepartmentOptions()]);
            break;

        case 'supervisor_options':
            echo json_encode(['success' => true, 'data' => UserRegistration::getEligibleSupervisors($user['id'], $user['department'])]);
            break;

        case 'update_details':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(updateDepartmentUserDetails($_GET['id'] ?? null, $user, parseRequestPayload()));
            break;

        case 'approve_user':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(approveDepartmentUser($_GET['id'] ?? null, $user));
            break;

        case 'reject_user':
            if ($method !== 'DELETE') throw new Exception('Method not allowed');
            echo json_encode(rejectDepartmentUser($_GET['id'] ?? null, $user));
            break;

        case 'device_requests':
            echo json_encode(getSupervisorDeviceRequests($user));
            break;

        case 'approve_device_request':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(resolveSupervisorDeviceRequest($_GET['id'] ?? null, 'approved', $user, parseRequestPayload()['webauthn_response'] ?? null));
            break;

        case 'reject_device_request':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(resolveSupervisorDeviceRequest($_GET['id'] ?? null, 'rejected', $user));
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
        "SELECT u.id, u.username, u.email, u.full_name, u.department, u.position, u.is_active, u.password_set, u.created_at,
                u.supervisor_id, sup.full_name AS supervisor_name
         FROM users u
         LEFT JOIN users sup ON u.supervisor_id = sup.id
         WHERE u.department = ? AND u.id <> ? AND u.is_active = 0 AND u.password_set = 1
         ORDER BY u.created_at DESC",
        [$user['department'], $user['id']]
    );

    return ['success' => true, 'data' => $users];
}

function assertOwnDepartmentUser($id, $user) {
    global $db;

    if (!$id) {
        throw new Exception('User ID required');
    }

    $target = $db->getRow("SELECT id, department, position FROM users WHERE id = ?", [$id]);
    if (!$target || $target['department'] !== $user['department']) {
        throw new Exception('User not found in your department');
    }

    return $target;
}

function approveDepartmentUser($id, $user) {
    global $db;

    assertOwnDepartmentUser($id, $user);

    $db->execute("UPDATE users SET is_active = 1 WHERE id = ?", [$id]);
    Auth::auditLog($user['id'], 'approve_user', 'user', $id);

    return ['success' => true, 'message' => 'User approved'];
}

function updateDepartmentUserDetails($id, $user, $data) {
    global $db;

    $target = assertOwnDepartmentUser($id, $user);

    $updates = [];
    $values = [];

    $department = $data['department'] ?? $target['department'];
    $position = $data['position'] ?? $target['position'];
    if (isset($data['department']) || isset($data['position'])) {
        if (!UserRegistration::isValidDepartmentPosition($department, $position)) {
            throw new Exception('Please select a valid position for the chosen department');
        }
        if (isset($data['department'])) {
            $updates[] = "department = ?";
            $values[] = $department;
        }
        if (isset($data['position'])) {
            $updates[] = "position = ?";
            $values[] = $position;
        }
    }
    if (isset($data['supervisor_id'])) {
        $supervisorId = (int) $data['supervisor_id'];
        if (!UserRegistration::isEligibleSupervisor($supervisorId, $id, $department)) {
            throw new Exception('Please select a valid immediate supervisor');
        }
        $updates[] = "supervisor_id = ?";
        $values[] = $supervisorId;
    }

    if (empty($updates)) {
        throw new Exception('No fields to update');
    }

    $values[] = $id;
    $db->execute("UPDATE users SET " . implode(', ', $updates) . " WHERE id = ?", $values);
    Auth::auditLog($user['id'], 'update_user_details', 'user', $id);

    return ['success' => true, 'message' => 'User details updated'];
}

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

function resolveSupervisorDeviceRequest($id, $status, $user, $webauthnResponse = null) {
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

    return DeviceChangeRequest::resolve($id, $status, $user, $webauthnResponse);
}

function rejectDepartmentUser($id, $user) {
    global $db;

    assertOwnDepartmentUser($id, $user);

    $db->execute("DELETE FROM users WHERE id = ?", [$id]);
    Auth::auditLog($user['id'], 'reject_user', 'user', $id);

    return ['success' => true, 'message' => 'User rejected'];
}
