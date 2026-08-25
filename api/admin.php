<?php
/**
 * API - Admin Functions
 */

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../src/database/Database.php';
require_once __DIR__ . '/../src/auth/Auth.php';
require_once __DIR__ . '/../src/security/DigitalSignature.php';

header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

// Check authentication and admin role
$user = Auth::getCurrentUser();
if (!$user || $user['role'] !== 'admin') {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

$db = Database::getInstance();

try {
    switch ($action) {
        case 'users':
            echo json_encode(getUsers());
            break;

        case 'user_details':
            if (empty($_GET['id'])) throw new Exception('User ID required');
            echo json_encode(getUserDetails($_GET['id']));
            break;

        case 'create_user':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            echo json_encode(createUser($_POST));
            break;

        case 'update_user':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            parse_str(file_get_contents('php://input'), $_PUT);
            echo json_encode(updateUser($_GET['id'] ?? null, $_PUT));
            break;

        case 'delete_user':
            if ($method !== 'DELETE') throw new Exception('Method not allowed');
            echo json_encode(deleteUser($_GET['id'] ?? null));
            break;

        case 'leave_types':
            echo json_encode(getLeaveTypes());
            break;

        case 'create_leave_type':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            echo json_encode(createLeaveType($_POST));
            break;

        case 'update_leave_type':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            parse_str(file_get_contents('php://input'), $_PUT);
            echo json_encode(updateLeaveType($_GET['id'] ?? null, $_PUT));
            break;

        case 'audit_log':
            echo json_encode(getAuditLog());
            break;

        case 'statistics':
            echo json_encode(getStatistics());
            break;

        default:
            throw new Exception('Invalid action');
    }
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}

function getUsers() {
    global $db;
    
    $users = $db->getResults(
        "SELECT id, username, email, full_name, department, role, is_active, created_at 
         FROM users 
         ORDER BY created_at DESC"
    );

    return ['success' => true, 'data' => $users];
}

function getUserDetails($id) {
    global $db;
    
    $user = $db->getRow(
        "SELECT id, username, email, full_name, department, role, is_active, created_at, updated_at 
         FROM users 
         WHERE id = ?",
        [$id]
    );

    if (!$user) {
        throw new Exception('User not found');
    }

    return ['success' => true, 'data' => $user];
}

function createUser($data) {
    global $db;

    $required = ['username', 'email', 'password', 'full_name'];
    foreach ($required as $field) {
        if (empty($data[$field])) {
            throw new Exception("$field is required");
        }
    }

    if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL) || !Auth::isAllowedEmailDomain($data['email'])) {
        throw new Exception('Email must be a @' . ALLOWED_EMAIL_DOMAIN . ' address');
    }

    // Check if user exists
    $existing = $db->getRow(
        "SELECT id FROM users WHERE email = ? OR username = ?",
        [$data['email'], $data['username']]
    );

    if ($existing) {
        throw new Exception('User already exists');
    }

    // Hash password
    $password_hash = password_hash($data['password'], PASSWORD_BCRYPT);

    // Generate RSA key pair so the user can digitally sign approvals
    $key_pair = DigitalSignature::generateKeyPair();

    // Insert user
    $sql = "INSERT INTO users (username, email, password_hash, full_name, department, role, public_key, is_active) 
            VALUES (?, ?, ?, ?, ?, ?, ?, 1)";

    $db->execute($sql, [
        $data['username'],
        $data['email'],
        $password_hash,
        $data['full_name'],
        $data['department'] ?? 'General',
        $data['role'] ?? 'employee',
        $key_pair['public_key']
    ]);

    Auth::auditLog($_SESSION['user_id'], 'create_user', 'user', $db->lastInsertId());

    return ['success' => true, 'message' => 'User created', 'id' => $db->lastInsertId()];
}

function updateUser($id, $data) {
    global $db;

    if (!$id) throw new Exception('User ID required');

    $user = $db->getRow("SELECT id FROM users WHERE id = ?", [$id]);
    if (!$user) throw new Exception('User not found');

    $updates = [];
    $values = [];

    if (isset($data['full_name'])) {
        $updates[] = "full_name = ?";
        $values[] = $data['full_name'];
    }
    if (isset($data['department'])) {
        $updates[] = "department = ?";
        $values[] = $data['department'];
    }
    if (isset($data['role'])) {
        $updates[] = "role = ?";
        $values[] = $data['role'];
    }
    if (isset($data['is_active'])) {
        $updates[] = "is_active = ?";
        $values[] = $data['is_active'];
    }

    if (empty($updates)) {
        throw new Exception('No fields to update');
    }

    $values[] = $id;
    $sql = "UPDATE users SET " . implode(', ', $updates) . " WHERE id = ?";
    $db->execute($sql, $values);

    Auth::auditLog($_SESSION['user_id'], 'update_user', 'user', $id);

    return ['success' => true, 'message' => 'User updated'];
}

function deleteUser($id) {
    global $db;

    if (!$id) throw new Exception('User ID required');

    $user = $db->getRow("SELECT id FROM users WHERE id = ?", [$id]);
    if (!$user) throw new Exception('User not found');

    $db->execute("DELETE FROM users WHERE id = ?", [$id]);

    Auth::auditLog($_SESSION['user_id'], 'delete_user', 'user', $id);

    return ['success' => true, 'message' => 'User deleted'];
}

function getLeaveTypes() {
    global $db;
    
    $types = $db->getResults(
        "SELECT id, name, description, days_per_year, is_paid, requires_documentation 
         FROM leave_types 
         ORDER BY name"
    );

    return ['success' => true, 'data' => $types];
}

function createLeaveType($data) {
    global $db;

    if (empty($data['name']) || empty($data['days_per_year'])) {
        throw new Exception('Name and days per year are required');
    }

    $sql = "INSERT INTO leave_types (name, description, days_per_year, is_paid, requires_documentation) 
            VALUES (?, ?, ?, ?, ?)";

    $db->execute($sql, [
        $data['name'],
        $data['description'] ?? '',
        $data['days_per_year'],
        isset($data['is_paid']) ? $data['is_paid'] : 1,
        isset($data['requires_documentation']) ? $data['requires_documentation'] : 0
    ]);

    return ['success' => true, 'message' => 'Leave type created'];
}

function updateLeaveType($id, $data) {
    global $db;

    if (!$id) throw new Exception('Leave type ID required');

    $type = $db->getRow("SELECT id FROM leave_types WHERE id = ?", [$id]);
    if (!$type) throw new Exception('Leave type not found');

    $updates = [];
    $values = [];

    if (isset($data['name'])) {
        $updates[] = "name = ?";
        $values[] = $data['name'];
    }
    if (isset($data['days_per_year'])) {
        $updates[] = "days_per_year = ?";
        $values[] = $data['days_per_year'];
    }
    if (isset($data['is_paid'])) {
        $updates[] = "is_paid = ?";
        $values[] = $data['is_paid'];
    }

    if (empty($updates)) throw new Exception('No fields to update');

    $values[] = $id;
    $sql = "UPDATE leave_types SET " . implode(', ', $updates) . " WHERE id = ?";
    $db->execute($sql, $values);

    return ['success' => true, 'message' => 'Leave type updated'];
}

function getAuditLog() {
    global $db;
    
    $logs = $db->getResults(
        "SELECT al.*, u.full_name 
         FROM audit_log al
         LEFT JOIN users u ON al.user_id = u.id
         ORDER BY al.created_at DESC
         LIMIT 1000"
    );

    return ['success' => true, 'data' => $logs];
}

function getStatistics() {
    global $db;
    
    $stats = [
        'total_users' => $db->getRow("SELECT COUNT(*) as count FROM users")['count'],
        'total_leave_requests' => $db->getRow("SELECT COUNT(*) as count FROM leave_requests")['count'],
        'pending_requests' => $db->getRow("SELECT COUNT(*) as count FROM leave_requests WHERE status = 'pending'")['count'],
        'approved_requests' => $db->getRow("SELECT COUNT(*) as count FROM leave_requests WHERE status = 'approved'")['count'],
        'rejected_requests' => $db->getRow("SELECT COUNT(*) as count FROM leave_requests WHERE status = 'rejected'")['count']
    ];

    return ['success' => true, 'data' => $stats];
}
?>
