<?php
/**
 * API - Leave Requests Management
 */

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../src/database/Database.php';
require_once __DIR__ . '/../src/auth/Auth.php';
require_once __DIR__ . '/../src/security/DeviceFingerprint.php';
require_once __DIR__ . '/../src/security/DigitalSignature.php';
require_once __DIR__ . '/../src/security/WebAuthnService.php';

header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';
$data = parseRequestPayload();

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
            echo json_encode(createLeaveRequest($data, $user));
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
            echo json_encode(updateLeaveRequest($_GET['id'] ?? null, parseRequestPayload(), $user));
            break;

        case 'approve':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            echo json_encode(approveLeaveRequest($data, $user));
            break;

        case 'reject':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            echo json_encode(rejectLeaveRequest($data, $user));
            break;

        case 'balance':
            echo json_encode(getLeaveBalance($user['id']));
            break;

        case 'leave_types':
            echo json_encode(getAvailableLeaveTypes($user));
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

    $leaveType = $db->getRow("SELECT id, name FROM leave_types WHERE id = ?", [$data['leave_type_id']]);
    if (!$leaveType) {
        throw new Exception('Invalid leave type');
    }

    if ($leaveType['name'] === 'Maternity Leave' && $user['gender'] !== 'female') {
        throw new Exception('Maternity Leave is only available to female employees');
    }

    if ($leaveType['name'] === 'Paternity Leave' && $user['gender'] !== 'male') {
        throw new Exception('Paternity Leave is only available to male employees');
    }

    if ($leaveType['name'] === 'Vacation Leave') {
        $today = new DateTime('today');
        if ($today->diff($start)->days < 3 || $start < $today) {
            throw new Exception('Vacation Leave must be filed at least 3 days before the requested start date');
        }
    }

    if ($leaveType['name'] === 'Leave Without Pay') {
        $remaining = $db->getRow(
            "SELECT COALESCE(SUM(lb.balance), 0) AS total_remaining
             FROM leave_balances lb
             JOIN leave_types lt ON lb.leave_type_id = lt.id
             WHERE lb.user_id = ? AND lt.name IN ('Vacation Leave', 'Sick Leave')",
            [$user['id']]
        );
        if ((float) ($remaining['total_remaining'] ?? 0) > 0) {
            throw new Exception('Leave Without Pay can only be filed once Vacation and Sick leave balances are exhausted');
        }
    }

    // Check leave balance
    $balance = $db->getRow(
        "SELECT balance FROM leave_balances WHERE user_id = ? AND leave_type_id = ?",
        [$user['id'], $data['leave_type_id']]
    );

    if (!$balance || $balance['balance'] < $days) {
        throw new Exception('Insufficient leave balance');
    }

    if (!DeviceFingerprint::verifyTrustedDevice($user['id'], $data)) {
        throw new Exception('Only registered and trusted devices can submit leave requests.');
    }

        $employee = $db->getRow("SELECT supervisor_id FROM users WHERE id = ?", [$user['id']]);

    // Tier 1 (employee) needs supervisor approval then HR approval; Tier 2 (manager) skips
    // straight to HR; Tier 3 (hr) / System Administrator's own leave is self-exempt.
    $isSelfExempt = in_array($user['role'], ['hr', 'admin'], true);
    $supervisorStatus = $user['role'] === 'manager' ? 'not_required' : 'pending';
    $status = $isSelfExempt ? 'approved' : 'pending';
    if ($isSelfExempt) {
        $supervisorStatus = 'not_required';
    }
    $hrStatus = $isSelfExempt ? 'approved' : 'pending';

    // Create leave request
    $sql = "INSERT INTO leave_requests
            (user_id, leave_type_id, start_date, end_date, number_of_days, reason, status, supervisor_status, hr_status, manager_id)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    if (!$db->execute($sql, [
        $user['id'],
        $data['leave_type_id'],
        $data['start_date'],
        $data['end_date'],
        $days,
        $data['reason'],
        $status,
        $supervisorStatus,
        $hrStatus,
        $employee['supervisor_id'] ?? null
    ])) {
        throw new Exception('Failed to create leave request');
    }

    $request_id = $db->lastInsertId();

    if ($isSelfExempt) {
        // Self-exempt: credit used days directly, no pending stage needed
        $db->execute(
            "UPDATE leave_balances SET used_days = used_days + ? WHERE user_id = ? AND leave_type_id = ?",
            [$days, $user['id'], $data['leave_type_id']]
        );
    } else {
        // Update leave balance
        $db->execute(
            "UPDATE leave_balances SET pending_days = pending_days + ? WHERE user_id = ? AND leave_type_id = ?",
            [$days, $user['id'], $data['leave_type_id']]
        );

        // Notify whoever needs to act on this first (supervisor for Tier 1, HR for Tier 2)
        notifyNextApprover($user, "New leave request from {$user['full_name']}", $request_id);
    }

    Auth::auditLog($user['id'], 'create_leave_request', 'leave_request', $request_id);

    return ['success' => true, 'message' => 'Leave request created', 'id' => $request_id];
}

function listLeaveRequests($user) {
    global $db;

    if ($user['role'] === 'manager') {
        // Managers see requests from their direct reports (Tier 1 employees who chose them as supervisor)
        $sql = "SELECT lr.*, u.full_name, lt.name as leave_type_name, COUNT(*) OVER() as total 
                FROM leave_requests lr
                JOIN users u ON lr.user_id = u.id
                JOIN leave_types lt ON lr.leave_type_id = lt.id
                WHERE u.supervisor_id = ?
                ORDER BY lr.created_at DESC
                LIMIT 50";
        $requests = $db->getResults($sql, [$user['id']]);
    } else if ($user['role'] === 'hr') {
        // HR sees requests that have reached (or passed) the HR stage
        $sql = "SELECT lr.*, u.full_name, lt.name as leave_type_name, COUNT(*) OVER() as total 
                FROM leave_requests lr
                JOIN users u ON lr.user_id = u.id
                JOIN leave_types lt ON lr.leave_type_id = lt.id
                WHERE lr.supervisor_status IN ('approved', 'not_required')
                ORDER BY lr.created_at DESC
                LIMIT 50";
        $requests = $db->getResults($sql, []);
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
    if (!in_array($user['role'], ['admin', 'manager', 'hr'], true) && $request['user_id'] != $user['id']) {
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

    if (!in_array($user['role'], ['manager', 'hr', 'admin'], true)) {
        throw new Exception('Unauthorized to approve requests');
    }

    if (empty($data['id'])) {
        throw new Exception('Leave request ID required');
    }

    $request = $db->getRow(
        "SELECT lr.*, u.supervisor_id as requester_supervisor_id
         FROM leave_requests lr JOIN users u ON lr.user_id = u.id WHERE lr.id = ?",
        [$data['id']]
    );

    if (!$request || $request['status'] !== 'pending') {
        throw new Exception('Invalid leave request');
    }

    if (empty($data['webauthn_response'])) {
        throw new Exception('A passkey approval is required to approve this request.');
    }

    $stage = currentApprovalStage($request);

    if ($stage === 'supervisor') {
        if ($user['role'] === 'manager' && (int) $request['requester_supervisor_id'] !== (int) $user['id']) {
            throw new Exception('Unauthorized to approve requests');
        }
    } elseif ($stage === 'hr') {
        if (!in_array($user['role'], ['hr', 'admin'], true)) {
            throw new Exception('Unauthorized to approve requests');
        }
    } else {
        throw new Exception('This request has already been resolved');
    }

    // Verify the passkey assertion and record it as the digital signature
    try {
        $assertionSignature = WebAuthnService::verifyApproval($user, $data['webauthn_response'], 'leave_request', (int) $data['id']);
        DigitalSignature::recordWebAuthnApproval($data['id'], $user['id'], $assertionSignature);
    } catch (Exception $e) {
        throw new Exception('Passkey verification failed: ' . $e->getMessage());
    }

    if ($stage === 'supervisor') {
        $db->execute(
            "UPDATE leave_requests SET supervisor_status = 'approved', manager_id = ?, manager_comments = ? WHERE id = ?",
            [$user['id'], $data['comments'] ?? '', $data['id']]
        );

        notifyHR("New leave request awaiting HR approval", $data['id']);
        createNotification(
            $request['user_id'],
            'Leave Request: Supervisor Approved',
            "Your supervisor approved your leave request from {$request['start_date']} to {$request['end_date']}. It now awaits HR approval.",
            'leave_request',
            $data['id']
        );

        Auth::auditLog($user['id'], 'approve_leave_request_supervisor', 'leave_request', $data['id']);
        return ['success' => true, 'message' => 'Leave request approved by supervisor; awaiting HR'];
    }

    // HR stage: finalize the request
    $db->execute(
        "UPDATE leave_requests SET status = 'approved', hr_status = 'approved', hr_id = ?, hr_comments = ? WHERE id = ?",
        [$user['id'], $data['comments'] ?? '', $data['id']]
    );

    // Move the days from pending to used now that it's fully approved
    $db->execute(
        "UPDATE leave_balances 
         SET pending_days = pending_days - ?, used_days = used_days + ? 
         WHERE user_id = ? AND leave_type_id = ?",
        [$request['number_of_days'], $request['number_of_days'], $request['user_id'], $request['leave_type_id']]
    );

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

    if (!in_array($user['role'], ['manager', 'hr', 'admin'], true)) {
        throw new Exception('Unauthorized to reject requests');
    }

    if (empty($data['id'])) {
        throw new Exception('Leave request ID required');
    }

    $request = $db->getRow(
        "SELECT lr.*, u.supervisor_id as requester_supervisor_id
         FROM leave_requests lr JOIN users u ON lr.user_id = u.id WHERE lr.id = ?",
        [$data['id']]
    );

    if (!$request || $request['status'] !== 'pending') {
        throw new Exception('Invalid leave request');
    }

    $stage = currentApprovalStage($request);

    if ($stage === 'supervisor') {
        if ($user['role'] === 'manager' && (int) $request['requester_supervisor_id'] !== (int) $user['id']) {
            throw new Exception('Unauthorized to reject requests');
        }
        $db->execute(
            "UPDATE leave_requests SET status = 'rejected', supervisor_status = 'rejected', manager_id = ?, manager_comments = ? WHERE id = ?",
            [$user['id'], $data['comments'] ?? '', $data['id']]
        );
    } elseif ($stage === 'hr') {
        if (!in_array($user['role'], ['hr', 'admin'], true)) {
            throw new Exception('Unauthorized to reject requests');
        }
        $db->execute(
            "UPDATE leave_requests SET status = 'rejected', hr_status = 'rejected', hr_id = ?, hr_comments = ? WHERE id = ?",
            [$user['id'], $data['comments'] ?? '', $data['id']]
        );
    } else {
        throw new Exception('This request has already been resolved');
    }

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

/**
 * Which stage a pending request is currently waiting on, so an approve/reject
 * action can be validated and routed to the right columns.
 */
function currentApprovalStage($request) {
    if ($request['supervisor_status'] === 'pending') {
        return 'supervisor';
    }
    if (in_array($request['supervisor_status'], ['approved', 'not_required'], true) && $request['hr_status'] === 'pending') {
        return 'hr';
    }
    return null;
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

/**
 * Leave types the requesting user is allowed to file, excluding gender-restricted
 * types (Maternity/Paternity) that don't apply to them.
 */
function getAvailableLeaveTypes($user) {
    global $db;

    $types = $db->getResults("SELECT id, name FROM leave_types ORDER BY name");
    $types = array_values(array_filter($types, function ($type) use ($user) {
        if ($type['name'] === 'Maternity Leave') {
            return $user['gender'] === 'female';
        }
        if ($type['name'] === 'Paternity Leave') {
            return $user['gender'] === 'male';
        }
        return true;
    }));

    return ['success' => true, 'data' => $types];
}

/**
 * Notify whoever needs to act first on a newly-created request: the requester's
 * supervisor for Tier 1 (employee), or HR directly for Tier 2 (manager).
 */
function notifyNextApprover($requester, $message, $entity_id) {
    global $db;

    if ($requester['role'] === 'manager') {
        notifyHR($message, $entity_id);
        return;
    }

    $approvers = $requester['supervisor_id']
        ? $db->getResults("SELECT id FROM users WHERE id = ? AND is_active = 1 AND role IN ('manager', 'admin')", [$requester['supervisor_id']])
        : $db->getResults("SELECT id FROM users WHERE role = 'manager' AND department = ? AND is_active = 1", [$requester['department']]);

    // No supervisor on file for this employee: fall back to the System Administrator
    if (empty($approvers)) {
        $approvers = $db->getResults("SELECT id FROM users WHERE role = 'admin' AND is_active = 1");
    }

    foreach ($approvers as $approver) {
        createNotification($approver['id'], 'New Leave Request', $message, 'leave_request', $entity_id);
    }
}

function notifyHR($message, $entity_id) {
    global $db;

    $hrUsers = $db->getResults("SELECT id FROM users WHERE role = 'hr' AND is_active = 1");
    foreach ($hrUsers as $hrUser) {
        createNotification($hrUser['id'], 'New Leave Request', $message, 'leave_request', $entity_id);
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
