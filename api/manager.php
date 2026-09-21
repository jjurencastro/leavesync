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
require_once __DIR__ . '/../src/leave/ManagerLeaveQueue.php';
require_once __DIR__ . '/../src/security/Permission.php';

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

        case 'leave_summary':
            echo json_encode(getManagerLeaveSummary($user, $_GET['status'] ?? 'all', $_GET['search'] ?? ''));
            break;

        case 'calendar':
            echo json_encode(getManagerCalendar($user, $_GET['from'] ?? date('Y-m-01'), $_GET['to'] ?? date('Y-m-t')));
            break;

        case 'analytics':
            echo json_encode(getManagerAnalytics($user, $_GET['from'] ?? date('Y-01-01'), $_GET['to'] ?? date('Y-12-31')));
            break;

        case 'escalate_leave':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            echo json_encode(escalateLeaveRequest($_GET['id'] ?? null, parseRequestPayload(), $user));
            break;

        case 'delegation_options':
            echo json_encode(getManagerDelegationOptions($user));
            break;

        case 'update_delegation':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(updateManagerDelegation($user, parseRequestPayload()));
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

function getManagerLeaveSummary($user, $status, $search) {
    global $db;

    $requests = $db->getResults(
        "SELECT lr.*, u.full_name, lt.name AS leave_type_name
         FROM leave_requests lr
         JOIN users u ON lr.user_id = u.id
         JOIN leave_types lt ON lr.leave_type_id = lt.id
         WHERE lr.assigned_supervisor_id = ? OR lr.manager_id = ? OR u.supervisor_id = ? OR lr.user_id = ?
         ORDER BY lr.created_at DESC LIMIT 50",
        [$user['id'], $user['id'], $user['id'], $user['id']]
    );

    foreach ($requests as &$request) {
        $request['overall_status'] = $request['status'];
    }
    unset($request);

    return ['success' => true, 'data' => ManagerLeaveQueue::summarize(ManagerLeaveQueue::filter($requests, $status, $search))];
}

function getManagerDelegationOptions($user) {
    global $db;

    $options = $db->getResults(
        "SELECT id, full_name, department, position
         FROM users
         WHERE id <> ? AND role IN ('manager', 'admin') AND is_active = 1
         ORDER BY full_name",
        [$user['id']]
    );
    $current = $db->getRow("SELECT backup_approver_id FROM users WHERE id = ?", [$user['id']]);

    return ['success' => true, 'data' => $options, 'backup_approver_id' => $current['backup_approver_id'] ?? null];
}

function getManagerCalendar($user, $from, $to) {
    global $db;
    $rows = $db->getResults(
        "SELECT lr.id, lr.user_id, u.full_name, u.department, lt.name AS leave_type_name,
                lr.start_date, lr.end_date, lr.number_of_days, lr.status
         FROM leave_requests lr JOIN users u ON lr.user_id = u.id JOIN leave_types lt ON lr.leave_type_id = lt.id
         WHERE (u.supervisor_id = ? OR lr.assigned_supervisor_id = ? OR lr.manager_id = ?)
           AND lr.status IN ('pending', 'approved') AND lr.start_date <= ? AND lr.end_date >= ?
         ORDER BY lr.start_date, u.full_name",
        [$user['id'], $user['id'], $user['id'], $to, $from]
    );
    return ['success' => true, 'data' => $rows];
}

function getManagerAnalytics($user, $from, $to) {
    global $db;
    $base = "FROM leave_requests lr JOIN users u ON lr.user_id = u.id JOIN leave_types lt ON lr.leave_type_id = lt.id
             WHERE (u.supervisor_id = ? OR lr.assigned_supervisor_id = ? OR lr.manager_id = ?)
               AND lr.start_date <= ? AND lr.end_date >= ?";
    $params = [$user['id'], $user['id'], $user['id'], $to, $from];
    $byType = $db->getResults("SELECT lt.name AS leave_type_name, COUNT(*) AS requests, COALESCE(SUM(lr.number_of_days), 0) AS days $base GROUP BY lt.id, lt.name ORDER BY days DESC", $params);
    $byStatus = $db->getResults("SELECT lr.status, COUNT(*) AS requests, COALESCE(SUM(lr.number_of_days), 0) AS days $base GROUP BY lr.status", $params);
    return ['success' => true, 'data' => ['from' => $from, 'to' => $to, 'by_leave_type' => $byType, 'by_status' => $byStatus]];
}

function escalateLeaveRequest($id, $data, $user) {
    global $db;
    if (!$id || empty($data['reason'])) throw new Exception('Leave request and escalation reason are required');
    $request = $db->getRow(
        "SELECT lr.id, lr.user_id, lr.status, lr.supervisor_status, lr.assigned_supervisor_id, u.supervisor_id AS requester_supervisor_id
         FROM leave_requests lr JOIN users u ON lr.user_id = u.id WHERE lr.id = ?",
        [$id]
    );
    if (!$request || $request['status'] !== 'pending') throw new Exception('Pending leave request not found');
    if ((int) $request['assigned_supervisor_id'] !== (int) $user['id'] && (int) ($request['requester_supervisor_id'] ?? 0) !== (int) $user['id']) {
        throw new Exception('You cannot escalate this request');
    }

    $toUserId = (int) ($data['to_user_id'] ?? 0);
    if ($toUserId <= 0) throw new Exception('Escalation target is required');
    $target = $db->getRow("SELECT id FROM users WHERE id = ? AND role IN ('manager', 'hr', 'admin') AND is_active = 1", [$toUserId]);
    if (!$target) throw new Exception('Escalation target is not an active approver');

    $db->execute(
        "INSERT INTO approval_escalations (leave_request_id, from_user_id, to_user_id, reason) VALUES (?, ?, ?, ?)",
        [$id, $user['id'], $toUserId, trim($data['reason'])]
    );
    $db->execute(
        "INSERT INTO notifications (user_id, title, message, notification_type, related_entity_type, related_entity_id)
         VALUES (?, ?, ?, ?, ?, ?)",
        [$toUserId, 'Leave Request Escalated', 'A leave request requires your attention.', 'info', 'leave_request', $id]
    );
    Auth::auditLog($user['id'], 'escalate_leave_request', 'leave_request', $id, ['to_user_id' => $toUserId, 'reason' => $data['reason']]);
    return ['success' => true, 'message' => 'Leave request escalated'];
}

function updateManagerDelegation($user, $data) {
    global $db;

    $backupId = (int) ($data['backup_approver_id'] ?? 0);
    if ($backupId === (int) $user['id']) {
        throw new Exception('A manager cannot delegate approval to themselves');
    }

    if ($backupId > 0) {
        $eligible = $db->getRow(
            "SELECT id FROM users WHERE id = ? AND role IN ('manager', 'admin') AND is_active = 1",
            [$backupId]
        );
        if (!$eligible) {
            throw new Exception('Select an active manager or administrator as the backup approver');
        }
    }

    $db->execute("UPDATE users SET backup_approver_id = ? WHERE id = ?", [$backupId > 0 ? $backupId : null, $user['id']]);
    Auth::auditLog($user['id'], 'update_manager_delegation', 'user', $user['id'], ['backup_approver_id' => $backupId ?: null]);

    return ['success' => true, 'message' => $backupId > 0 ? 'Backup approver saved' : 'Backup approver cleared'];
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
