<?php
/**
 * API - HR Functions
 * Lets HR approve/reject pending user accounts assigned to them (e.g. Deans,
 * who report to HR) and device-change requests from their direct reports.
 */

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../src/database/Database.php';
require_once __DIR__ . '/../src/auth/Auth.php';
require_once __DIR__ . '/../src/auth/DeviceChangeRequest.php';
require_once __DIR__ . '/../src/auth/UserRegistration.php';
require_once __DIR__ . '/../src/security/DeviceFingerprint.php';
require_once __DIR__ . '/../src/security/Permission.php';
require_once __DIR__ . '/../src/database/SchemaSupport.php';

header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

$user = Auth::getCurrentUser();
if (!$user || $user['role'] !== 'hr') {
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
            echo json_encode(getPendingAssignedUsers($user));
            break;

        case 'department_positions':
            echo json_encode(['success' => true, 'data' => UserRegistration::getDepartmentOptions()]);
            break;

        case 'supervisor_options':
            echo json_encode(['success' => true, 'data' => UserRegistration::getEligibleSupervisors($user['id'])]);
            break;

        case 'update_details':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(updateAssignedUserDetails($_GET['id'] ?? null, $user, parseRequestPayload()));
            break;

        case 'approve_user':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(approveAssignedUser($_GET['id'] ?? null, $user));
            break;

        case 'reject_user':
            if ($method !== 'DELETE') throw new Exception('Method not allowed');
            echo json_encode(rejectAssignedUser($_GET['id'] ?? null, $user));
            break;

        case 'device_requests':
            echo json_encode(getDirectReportDeviceRequests($user));
            break;

        case 'statistics':
            echo json_encode(getHRStatistics($user));
            break;

        case 'employees':
            echo json_encode(getHREmployees());
            break;

        case 'reassign_employee':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(reassignEmployee($_GET['id'] ?? null, parseRequestPayload(), $user));
            break;

        case 'restore_employee':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(restoreEmployee($_GET['id'] ?? null, $user));
            break;

        case 'approve_device_request':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(resolveDirectReportDeviceRequest($_GET['id'] ?? null, 'approved', $user, parseRequestPayload()['webauthn_response'] ?? null));
            break;

        case 'reject_device_request':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(resolveDirectReportDeviceRequest($_GET['id'] ?? null, 'rejected', $user));
            break;

        default:
            throw new Exception('Invalid action');
    }
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}

/**
 * Pending accounts that chose this HR user as their supervisor (e.g. Deans,
 * who report to HR per the approval hierarchy).
 */
function getPendingAssignedUsers($user) {
    global $db;

    $users = $db->getResults(
        "SELECT u.id, u.username, u.email, u.full_name, u.department, u.position, u.is_active, u.password_set, u.created_at,
                u.supervisor_id, sup.full_name AS supervisor_name
         FROM users u
         LEFT JOIN users sup ON u.supervisor_id = sup.id
         WHERE u.supervisor_id = ? AND u.is_active = 0 AND u.password_set = 1
         ORDER BY u.created_at DESC",
        [$user['id']]
    );

    return ['success' => true, 'data' => $users];
}

/**
 * HR may only act on pending accounts assigned to them; active accounts are
 * managed by the System Administrator.
 */
function assertOwnPendingUser($id, $user) {
    global $db;

    if (!$id) {
        throw new Exception('User ID required');
    }

    $target = $db->getRow(
        "SELECT id, department, position FROM users WHERE id = ? AND is_active = 0 AND supervisor_id = ?",
        [$id, $user['id']]
    );
    if (!$target) {
        throw new Exception('Pending user not found in your approval queue');
    }

    return $target;
}

function approveAssignedUser($id, $user) {
    global $db;

    assertOwnPendingUser($id, $user);

    $db->execute("UPDATE users SET is_active = 1 WHERE id = ?", [$id]);
    Auth::auditLog($user['id'], 'approve_user', 'user', $id);

    return ['success' => true, 'message' => 'User approved'];
}

function updateAssignedUserDetails($id, $user, $data) {
    global $db;

    $target = assertOwnPendingUser($id, $user);

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
        if (!UserRegistration::isEligibleSupervisor($supervisorId, $id, $department, $position)) {
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

function rejectAssignedUser($id, $user) {
    global $db;

    assertOwnPendingUser($id, $user);

    $db->execute("DELETE FROM users WHERE id = ?", [$id]);
    Auth::auditLog($user['id'], 'reject_user', 'user', $id);

    return ['success' => true, 'message' => 'User rejected'];
}

/**
 * Device-change requests from this HR user's direct reports (Deans report to HR).
 */
function getDirectReportDeviceRequests($user) {
    $requests = DeviceChangeRequest::getPendingForHR($user['id']);

    foreach ($requests as &$request) {
        $info = json_decode($request['device_info'], true) ?: [];
        $request['changes'] = DeviceFingerprint::diffAgainstTrusted($request['user_id'], $info);
    }

    return ['success' => true, 'data' => $requests];
}

function getHRStatistics($user) {
    global $db;

    return [
        'success' => true,
        'data' => [
            'total_leave_requests' => $db->getRow("SELECT COUNT(*) AS count FROM leave_requests WHERE supervisor_status IN ('approved', 'not_required') OR status = 'rejected'")['count'],
            'pending_hr_requests' => $db->getRow("SELECT COUNT(*) AS count FROM leave_requests WHERE status = 'pending' AND hr_status = 'pending' AND supervisor_status IN ('approved', 'not_required')")['count'],
            'approved_leave_requests' => $db->getRow("SELECT COUNT(*) AS count FROM leave_requests WHERE status = 'approved'")['count'],
            'rejected_leave_requests' => $db->getRow("SELECT COUNT(*) AS count FROM leave_requests WHERE status = 'rejected'")['count'],
            'pending_device_requests' => $db->getRow("SELECT COUNT(*) AS count FROM device_change_requests dcr JOIN users u ON dcr.user_id = u.id WHERE dcr.status = 'pending' AND u.supervisor_id = ?", [$user['id']])['count'],
        ]
    ];
}

function getHREmployees() {
    global $db;
    return ['success' => true, 'data' => $db->getResults(
        "SELECT u.id, u.username, u.email, u.full_name, u.department, u.position, u.role, u.gender, u.is_active,
                u.supervisor_id, sup.full_name AS supervisor_name
         FROM users u LEFT JOIN users sup ON u.supervisor_id = sup.id
         WHERE u.role <> 'admin' ORDER BY u.department, u.full_name"
    )];
}

function reassignEmployee($id, $data, $user) {
    global $db;
    if (!$id) throw new Exception('Employee ID required');
    $target = $db->getRow("SELECT id, role, department FROM users WHERE id = ? AND role <> 'admin'", [$id]);
    if (!$target) throw new Exception('Employee not found');

    $updates = [];
    $values = [];
    if (isset($data['department'])) {
        $updates[] = 'department = ?';
        $values[] = trim((string) $data['department']);
    }
    if (isset($data['position'])) {
        $updates[] = 'position = ?';
        $values[] = trim((string) $data['position']);
    }
    if (isset($data['supervisor_id'])) {
        $supervisorId = (int) $data['supervisor_id'];
        $department = $data['department'] ?? $target['department'];
        if (!UserRegistration::isEligibleSupervisor($supervisorId, $id, $department, $data['position'] ?? null)) {
            throw new Exception('Selected supervisor is not eligible for this employee');
        }
        $updates[] = 'supervisor_id = ?';
        $values[] = $supervisorId;
    }
    if (!$updates) throw new Exception('No employee fields supplied');
    $values[] = $id;
    $db->execute('UPDATE users SET ' . implode(', ', $updates) . ' WHERE id = ?', $values);
    Auth::auditLog($user['id'], 'reassign_employee', 'user', $id, $data);
    return ['success' => true, 'message' => 'Employee record updated'];
}

function restoreEmployee($id, $user) {
    global $db;
    if (!$id) throw new Exception('Employee ID required');
    $target = $db->getRow("SELECT id FROM users WHERE id = ? AND role <> 'admin'", [$id]);
    if (!$target) throw new Exception('Employee not found');
    $sql = SchemaSupport::hasColumn($db, 'users', 'deleted_at')
        ? 'UPDATE users SET deleted_at = NULL, is_active = 1 WHERE id = ?'
        : 'UPDATE users SET is_active = 1 WHERE id = ?';
    $db->execute($sql, [$id]);
    Auth::auditLog($user['id'], 'restore_employee', 'user', $id);
    return ['success' => true, 'message' => 'Employee account restored'];
}

function resolveDirectReportDeviceRequest($id, $status, $user, $webauthnResponse = null) {
    global $db;

    if (!$id) throw new Exception('Request ID required');

    // Confirm this pending request actually belongs to one of this HR user's direct reports
    $request = $db->getRow(
        "SELECT dcr.id FROM device_change_requests dcr
         JOIN users u ON dcr.user_id = u.id
         WHERE dcr.id = ? AND dcr.status = 'pending' AND u.supervisor_id = ?",
        [$id, $user['id']]
    );
    if (!$request) throw new Exception('Pending device request not found');

    return DeviceChangeRequest::resolve($id, $status, $user, $webauthnResponse);
}
