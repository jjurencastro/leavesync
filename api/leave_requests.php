<?php
/**
 * API - Leave Requests Management
 */

require_once __DIR__ . '/../../config/config.php';
require_once __DIR__ . '/../../src/database/Database.php';
require_once __DIR__ . '/../../src/auth/Auth.php';
require_once __DIR__ . '/../../src/security/DigitalSignature.php';

header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

// Check authentication
if (!Auth::isAuthenticated()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

$user = Auth::getCurrentUser();
$db = Database::getInstance();

try {
    switch ($action) {
        case 'create':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            echo json_encode(createLeaveRequest($_POST, $user));
            break;

        case 'list':
            echo json_encode(listLeaveRequests($user));
            break;

        case 'get':
            if (empty($_GET['id'])) throw new Exception('Leave request ID required');
            echo json_encode(getLeaveRequest($_GET['id'], $user));
            break;

        case 'update':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            parse_str(file_get_contents('php://input'), $_PUT);
            echo json_encode(updateLeaveRequest($_GET['id'] ?? null, $_PUT, $user));
            break;

        case 'approve':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            echo json_encode(approveLeaveRequest($_POST, $user));
            break;

        case 'reject':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            echo json_encode(rejectLeaveRequest($_POST, $user));
            break;

        case 'balance':
            echo json_encode(getLeaveBalance($user['id']));
            break;

        default:
            throw new Exception('Invalid action');
    }
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}

function createLeaveRequest($data, $user) {
    global $db;

    $required = ['leave_type_id', 'start_date', 'end_date', 'reason'];
    foreach ($required as $field) {
        if (empty($data[$field])) {
            throw new Exception("$field is required");
        }
    }

    // Validate dates
    $start = new DateTime($data['start_date']);
    $end = new DateTime($data['end_date']);
    
    if ($end < $start) {
        throw new Exception('End date must be after start date');
    }

    $days = $start->diff($end)->days + 1;

    // Check leave balance
    $balance = $db->getRow(
        "SELECT balance FROM leave_balances WHERE user_id = ? AND leave_type_id = ?",
        [$user['id'], $data['leave_type_id']]
    );

    if (!$balance || $balance['balance'] < $days) {
        throw new Exception('Insufficient leave balance');
    }

    // Create leave request
    $sql = "INSERT INTO leave_requests 
            (user_id, leave_type_id, start_date, end_date, number_of_days, reason, status) 
            VALUES (?, ?, ?, ?, ?, ?, 'pending')";

    if (!$db->execute($sql, [
        $user['id'],
        $data['leave_type_id'],
        $data['start_date'],
        $data['end_date'],
        $days,
        $data['reason']
    ])) {
        throw new Exception('Failed to create leave request');
    }

    $request_id = $db->lastInsertId();

    // Update leave balance
    $db->execute(
        "UPDATE leave_balances SET pending_days = pending_days + ? WHERE user_id = ? AND leave_type_id = ?",
        [$days, $user['id'], $data['leave_type_id']]
    );

    // Create notification for managers
    notifyManagers($user['id'], "New leave request from {$user['full_name']}", $request_id);

    Auth::auditLog($user['id'], 'create_leave_request', 'leave_request', $request_id);

    return ['success' => true, 'message' => 'Leave request created', 'id' => $request_id];
}

function listLeaveRequests($user) {
    global $db;

    if ($user['role'] === 'manager') {
        // Managers see requests from their team
        $sql = "SELECT lr.*, u.full_name, lt.name as leave_type_name, COUNT(*) OVER() as total 
                FROM leave_requests lr
                JOIN users u ON lr.user_id = u.id
                JOIN leave_types lt ON lr.leave_type_id = lt.id
                WHERE lr.manager_id = ? OR u.department = ?
                ORDER BY lr.created_at DESC
                LIMIT 50";
        $requests = $db->getResults($sql, [$user['id'], $user['department']]);
    } else if ($user['role'] === 'admin') {
        // Admins see all requests
        $sql = "SELECT lr.*, u.full_name, lt.name as leave_type_name, COUNT(*) OVER() as total 
                FROM leave_requests lr
                JOIN users u ON lr.user_id = u.id
                JOIN leave_types lt ON lr.leave_type_id = lt.id
                ORDER BY lr.created_at DESC
                LIMIT 100";
        $requests = $db->getResults($sql, []);
    } else {
        // Employees see only their requests
        $sql = "SELECT lr.*, u.full_name, lt.name as leave_type_name, COUNT(*) OVER() as total 
                FROM leave_requests lr
                JOIN users u ON lr.user_id = u.id
                JOIN leave_types lt ON lr.leave_type_id = lt.id
                WHERE lr.user_id = ?
                ORDER BY lr.created_at DESC
                LIMIT 50";
        $requests = $db->getResults($sql, [$user['id']]);
    }

    return ['success' => true, 'data' => $requests];
}

function getLeaveRequest($id, $user) {
    global $db;

    $request = $db->getRow(
        "SELECT lr.*, u.full_name, u.email, lt.name as leave_type_name, m.full_name as manager_name 
         FROM leave_requests lr
         JOIN users u ON lr.user_id = u.id
         JOIN leave_types lt ON lr.leave_type_id = lt.id
         LEFT JOIN users m ON lr.manager_id = m.id
         WHERE lr.id = ?",
        [$id]
    );

    if (!$request) {
        throw new Exception('Leave request not found');
    }

    // Check authorization
    if ($user['role'] !== 'admin' && $user['role'] !== 'manager' && $request['user_id'] != $user['id']) {
        throw new Exception('Unauthorized');
    }

    // Get signature info if approved
    if ($request['status'] === 'approved' && $request['digital_signature']) {
        $signature_info = DigitalSignature::getSignatureInfo($request['id']);
        $request['signature_info'] = $signature_info;
    }

    return ['success' => true, 'data' => $request];
}

function updateLeaveRequest($id, $data, $user) {
    global $db;

    if (!$id) {
        throw new Exception('Leave request ID required');
    }

    $request = $db->getRow("SELECT * FROM leave_requests WHERE id = ?", [$id]);

    if (!$request) {
        throw new Exception('Leave request not found');
    }

    // Only allow updates if pending and user is owner
    if ($request['status'] !== 'pending' || $request['user_id'] != $user['id']) {
        throw new Exception('Cannot update this leave request');
    }

    $updatable = ['reason'];
    $updates = [];
    $values = [];

    foreach ($updatable as $field) {
        if (isset($data[$field])) {
            $updates[] = "$field = ?";
            $values[] = $data[$field];
        }
    }

    if (empty($updates)) {
        throw new Exception('No valid fields to update');
    }

    $values[] = $id;
    $sql = "UPDATE leave_requests SET " . implode(', ', $updates) . " WHERE id = ?";

    if (!$db->execute($sql, $values)) {
        throw new Exception('Failed to update leave request');
    }

    Auth::auditLog($user['id'], 'update_leave_request', 'leave_request', $id);

    return ['success' => true, 'message' => 'Leave request updated'];
}

function approveLeaveRequest($data, $user) {
    global $db;

    if (!in_array($user['role'], ['manager', 'admin'])) {
        throw new Exception('Unauthorized to approve requests');
    }

    if (empty($data['id'])) {
        throw new Exception('Leave request ID required');
    }

    $request = $db->getRow("SELECT * FROM leave_requests WHERE id = ?", [$data['id']]);

    if (!$request || $request['status'] !== 'pending') {
        throw new Exception('Invalid leave request');
    }

    // Sign the request digitally
    // Note: In production, manager's private key would be securely provided
    DigitalSignature::signLeaveRequest($data['id'], $data['private_key'] ?? '', $user['id']);

    // Update request status
    $sql = "UPDATE leave_requests 
            SET status = 'approved', manager_id = ?, manager_comments = ? 
            WHERE id = ?";

    $db->execute($sql, [
        $user['id'],
        $data['comments'] ?? '',
        $data['id']
    ]);

    // Update leave balance
    $db->execute(
        "UPDATE leave_balances 
         SET pending_days = pending_days - ?, used_days = used_days + ? 
         WHERE user_id = ? AND leave_type_id = ?",
        [$request['number_of_days'], $request['number_of_days'], $request['user_id'], $request['leave_type_id']]
    );

    // Notify employee
    $employee = $db->getRow("SELECT full_name FROM users WHERE id = ?", [$request['user_id']]);
    createNotification(
        $request['user_id'],
        'Leave Request Approved',
        "Your leave request from {$request['start_date']} to {$request['end_date']} has been approved.",
        'leave_request',
        $request['id']
    );

    Auth::auditLog($user['id'], 'approve_leave_request', 'leave_request', $data['id']);

    return ['success' => true, 'message' => 'Leave request approved'];
}

function rejectLeaveRequest($data, $user) {
    global $db;

    if (!in_array($user['role'], ['manager', 'admin'])) {
        throw new Exception('Unauthorized to reject requests');
    }

    if (empty($data['id'])) {
        throw new Exception('Leave request ID required');
    }

    $request = $db->getRow("SELECT * FROM leave_requests WHERE id = ?", [$data['id']]);

    if (!$request || $request['status'] !== 'pending') {
        throw new Exception('Invalid leave request');
    }

    // Update request status
    $sql = "UPDATE leave_requests 
            SET status = 'rejected', manager_id = ?, manager_comments = ? 
            WHERE id = ?";

    $db->execute($sql, [
        $user['id'],
        $data['comments'] ?? '',
        $data['id']
    ]);

    // Revert pending days to balance
    $db->execute(
        "UPDATE leave_balances 
         SET pending_days = pending_days - ?, balance = balance + ? 
         WHERE user_id = ? AND leave_type_id = ?",
        [$request['number_of_days'], $request['number_of_days'], $request['user_id'], $request['leave_type_id']]
    );

    // Notify employee
    createNotification(
        $request['user_id'],
        'Leave Request Rejected',
        "Your leave request from {$request['start_date']} to {$request['end_date']} has been rejected.",
        'leave_request',
        $request['id']
    );

    Auth::auditLog($user['id'], 'reject_leave_request', 'leave_request', $data['id']);

    return ['success' => true, 'message' => 'Leave request rejected'];
}

function getLeaveBalance($user_id) {
    global $db;

    $balances = $db->getResults(
        "SELECT lb.*, lt.name as leave_type_name 
         FROM leave_balances lb
         JOIN leave_types lt ON lb.leave_type_id = lt.id
         WHERE lb.user_id = ?",
        [$user_id]
    );

    return ['success' => true, 'data' => $balances];
}

function notifyManagers($user_id, $message, $entity_id) {
    global $db;

    $user = $db->getRow("SELECT department FROM users WHERE id = ?", [$user_id]);
    $managers = $db->getResults(
        "SELECT id FROM users WHERE role = 'manager' AND department = ?",
        [$user['department']]
    );

    foreach ($managers as $manager) {
        createNotification($manager['id'], 'New Leave Request', $message, 'leave_request', $entity_id);
    }
}

function createNotification($user_id, $title, $message, $type, $entity_id) {
    global $db;
    
    $db->execute(
        "INSERT INTO notifications (user_id, title, message, notification_type, related_entity_type, related_entity_id) 
         VALUES (?, ?, ?, ?, ?, ?)",
        [$user_id, $title, $message, 'info', $type, $entity_id]
    );
}
?>
