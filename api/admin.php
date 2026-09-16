<?php
/**
 * API - Admin Functions
 */

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../src/database/Database.php';
require_once __DIR__ . '/../src/auth/Auth.php';
require_once __DIR__ . '/../src/auth/DeviceChangeRequest.php';
require_once __DIR__ . '/../src/security/DigitalSignature.php';
require_once __DIR__ . '/../src/security/DeviceFingerprint.php';

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
if (empty($user['password_set']) || empty($user['is_active'])) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Account activation pending']);
    exit;
}

$db = Database::getInstance();

try {
    switch ($action) {
        case 'users':
            echo json_encode(getUsers());
            break;

        case 'department_positions':
            echo json_encode(['success' => true, 'data' => UserRegistration::getDepartmentOptions()]);
            break;

        case 'user_details':
            if (empty($_GET['id'])) throw new Exception('User ID required');
            echo json_encode(getUserDetails($_GET['id']));
            break;

        case 'create_user':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            echo json_encode(createUser($data = parseRequestPayload()));
            break;

        case 'bulk_create_users':
            if ($method !== 'POST') throw new Exception('Method not allowed');
            echo json_encode(bulkCreateUsers(parseRequestPayload()));
            break;

        case 'update_user':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(
                updateUser($_GET['id'] ?? null, parseRequestPayload()),
                JSON_INVALID_UTF8_SUBSTITUTE
            );
            break;

        case 'delete_user':
            if ($method !== 'DELETE') throw new Exception('Method not allowed');
            echo json_encode(deleteUser($_GET['id'] ?? null));
            break;

        case 'device_requests':
            echo json_encode(getDeviceChangeRequests());
            break;

        case 'approve_device_request':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(resolveDeviceChangeRequest($_GET['id'] ?? null, 'approved', $user, parseRequestPayload()['webauthn_response'] ?? null));
            break;

        case 'reject_device_request':
            if ($method !== 'PUT') throw new Exception('Method not allowed');
            echo json_encode(resolveDeviceChangeRequest($_GET['id'] ?? null, 'rejected', $user));
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

        case 'download_template':
            downloadUserTemplate();
            exit;

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
        "SELECT u.id, u.username, u.email, u.full_name, u.department, u.position, u.role, u.is_active, u.password_set, u.created_at,
                u.supervisor_id, sup.full_name AS supervisor_name
         FROM users u
         LEFT JOIN users sup ON u.supervisor_id = sup.id
         ORDER BY u.created_at DESC"
    );

    return ['success' => true, 'data' => $users];
}

function getUserDetails($id) {
    global $db;
    
    $user = $db->getRow(
        "SELECT id, username, email, full_name, department, position, role, is_active, created_at, updated_at 
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

    $required = ['username', 'email', 'full_name', 'gender', 'department', 'position', 'supervisor_id'];
    foreach ($required as $field) {
        if (empty($data[$field])) {
            throw new Exception("$field is required");
        }
    }

    if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL) || !Auth::isAllowedEmailDomain($data['email'])) {
        throw new Exception('Email must be a @' . ALLOWED_EMAIL_DOMAIN . ' address');
    }

    if (!in_array($data['gender'], ['male', 'female'], true)) {
        throw new Exception('Please select a valid gender option');
    }
    if (!UserRegistration::isValidDepartmentPosition($data['department'], $data['position'])) {
        throw new Exception('Please select a valid position for the chosen department');
    }

    $supervisorId = (int) $data['supervisor_id'];
    $isActiveAdminSupervisor = $db->getRow(
        "SELECT id FROM users WHERE id = ? AND is_active = 1 AND role = 'admin'",
        [$supervisorId]
    );
    if (!$isActiveAdminSupervisor && !UserRegistration::isEligibleSupervisor($supervisorId, 0, $data['department'], $data['position'])) {
        throw new Exception('Please select a valid immediate supervisor');
    }

    // Check if user exists
    $existing = $db->getRow(
        "SELECT id FROM users WHERE email = ? OR username = ?",
        [$data['email'], $data['username']]
    );

    if ($existing) {
        throw new Exception('User already exists');
    }

    // Keep the password unusable until the employee completes Google activation.
    $password_hash = password_hash(bin2hex(random_bytes(24)), PASSWORD_BCRYPT);

    // Generate RSA key pair so the user can digitally sign approvals
    $key_pair = DigitalSignature::generateKeyPair();

    // Insert user
        $sql = "INSERT INTO users (id, username, email, password_hash, full_name, department, position, gender, supervisor_id, role, public_key, is_active, password_set)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0)";

        $newUserId = Auth::reserveNextUserId();
        $values = [
            $newUserId,
        $data['username'],
        $data['email'],
        $password_hash,
        $data['full_name'],
        $data['department'] ?? 'General',
        $data['position'],
        $data['gender'],
        $supervisorId,
        UserRegistration::POSITION_ROLE_MAP[$data['position']],
        $key_pair['public_key']
    ];
    $db->execute($sql, $values);
    UserRegistration::initializeLeaveBalances($newUserId);

    Auth::auditLog($_SESSION['user_id'], 'create_user', 'user', $newUserId);

    return ['success' => true, 'message' => 'User created', 'id' => $newUserId];
}

function bulkCreateUsers($payload) {
    global $db;

    $users = $payload['users'] ?? null;
    if (!is_array($users) || empty($users)) {
        throw new Exception('No user records provided for bulk import');
    }

    if (count($users) > 500) {
        throw new Exception('A maximum of 500 users can be imported in a single batch');
    }

    $existingUsers = $db->getResults("SELECT id, username, LOWER(email) AS email FROM users");
    $existingUsernames = [];
    $existingEmails = [];
    foreach ($existingUsers as $u) {
        $existingUsernames[strtolower($u['username'])] = true;
        $existingEmails[strtolower($u['email'])] = true;
    }

    $batchUsernames = [];
    $batchEmails = [];
    $validatedRows = [];
    $errors = [];

    foreach ($users as $idx => $row) {
        $rowNum = $idx + 1;
        $username = trim($row['username'] ?? '');
        $email = strtolower(trim($row['email'] ?? ''));
        $fullName = trim($row['full_name'] ?? '');
        $gender = strtolower(trim($row['gender'] ?? ''));
        $department = trim($row['department'] ?? '');
        $position = trim($row['position'] ?? '');
        $supervisorIdentifier = trim($row['supervisor'] ?? ($row['supervisor_id'] ?? ''));

        $rowErrors = [];

        if (empty($username)) {
            $rowErrors[] = 'Username is required';
        } elseif (strlen($username) < 3) {
            $rowErrors[] = 'Username must be at least 3 characters';
        } elseif (isset($existingUsernames[strtolower($username)]) || isset($batchUsernames[strtolower($username)])) {
            $rowErrors[] = "Username '{$username}' already exists";
        }

        if (empty($email)) {
            $rowErrors[] = 'Email is required';
        } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL) || !Auth::isAllowedEmailDomain($email)) {
            $rowErrors[] = 'Email must be a valid @' . ALLOWED_EMAIL_DOMAIN . ' address';
        } elseif (isset($existingEmails[strtolower($email)]) || isset($batchEmails[strtolower($email)])) {
            $rowErrors[] = "Email '{$email}' already exists";
        }

        if (empty($fullName)) {
            $rowErrors[] = 'Full name is required';
        }

        if (!in_array($gender, ['male', 'female'], true)) {
            $rowErrors[] = 'Gender must be male or female';
        }

        if (!UserRegistration::isValidDepartmentPosition($department, $position)) {
            $rowErrors[] = "Invalid position '{$position}' for department '{$department}'";
        }

        $supervisorUser = null;
        if (empty($supervisorIdentifier)) {
            $rowErrors[] = 'Immediate supervisor is required';
        } else {
            $supervisorUser = UserRegistration::resolveEligibleSupervisor($supervisorIdentifier, 0, $department, $position);
            if (!$supervisorUser) {
                $rowErrors[] = "Supervisor '{$supervisorIdentifier}' is not eligible or not found for department '{$department}'";
            }
        }

        if (!empty($rowErrors)) {
            $errors[] = [
                'row' => $rowNum,
                'username' => $username,
                'email' => $email,
                'full_name' => $fullName,
                'errors' => $rowErrors
            ];
        } else {
            $batchUsernames[strtolower($username)] = true;
            $batchEmails[strtolower($email)] = true;
            $validatedRows[] = [
                'username' => $username,
                'email' => $email,
                'full_name' => $fullName,
                'gender' => $gender,
                'department' => $department,
                'position' => $position,
                'supervisor_id' => (int)$supervisorUser['id']
            ];
        }
    }

    if (!empty($errors)) {
        return [
            'success' => false,
            'message' => 'Bulk import validation failed with ' . count($errors) . ' invalid row(s)',
            'errors' => $errors,
            'valid_count' => count($validatedRows),
            'total_count' => count($users)
        ];
    }

    $createdIds = [];
    foreach ($validatedRows as $validData) {
        $password_hash = password_hash(bin2hex(random_bytes(24)), PASSWORD_BCRYPT);
        $key_pair = DigitalSignature::generateKeyPair();
        $newUserId = Auth::reserveNextUserId();

        $sql = "INSERT INTO users (id, username, email, password_hash, full_name, department, position, gender, supervisor_id, role, public_key, is_active, password_set)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0)";
        $values = [
            $newUserId,
            $validData['username'],
            $validData['email'],
            $password_hash,
            $validData['full_name'],
            $validData['department'],
            $validData['position'],
            $validData['gender'],
            $validData['supervisor_id'],
            UserRegistration::POSITION_ROLE_MAP[$validData['position']],
            $key_pair['public_key']
        ];
        $db->execute($sql, $values);
        UserRegistration::initializeLeaveBalances($newUserId);
        Auth::auditLog($_SESSION['user_id'], 'bulk_create_user', 'user', $newUserId);
        $createdIds[] = $newUserId;
    }

    return [
        'success' => true,
        'message' => count($createdIds) . ' user accounts created successfully',
        'created_count' => count($createdIds)
    ];
}

function updateUser($id, $data) {
    global $db;

    if (!$id) throw new Exception('User ID required');

    $user = $db->getRow("SELECT id, role, department, position FROM users WHERE id = ?", [$id]);
    if (!$user) throw new Exception('User not found');

    $updates = [];
    $values = [];

    if (isset($data['full_name'])) {
        $updates[] = "full_name = ?";
        $values[] = $data['full_name'];
    }
    if (isset($data['username']) || isset($data['email'])) {
        $username = trim($data['username'] ?? '');
        $email = strtolower(trim($data['email'] ?? ''));
        if (isset($data['username']) && strlen($username) < 3) {
            throw new Exception('Username must be at least 3 characters');
        }
        if (isset($data['email']) && (!filter_var($email, FILTER_VALIDATE_EMAIL) || !Auth::isAllowedEmailDomain($email))) {
            throw new Exception('Email must be a @' . ALLOWED_EMAIL_DOMAIN . ' address');
        }
        $duplicate = $db->getRow(
            "SELECT id FROM users WHERE id <> ? AND (username = ? OR LOWER(email) = LOWER(?))",
            [$id, $username, $email]
        );
        if ($duplicate) {
            throw new Exception('Username or email already belongs to another user');
        }
        if (isset($data['username'])) {
            $updates[] = "username = ?";
            $values[] = $username;
        }
        if (isset($data['email'])) {
            $updates[] = "email = ?";
            $values[] = $email;
        }
    }
    if (isset($data['department']) || isset($data['position'])) {
        $department = $data['department'] ?? $user['department'];
        $position = $data['position'] ?? $user['position'];
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
        if ($position === 'Dean') {
            $updates[] = "role = ?";
            $values[] = 'manager';
        }
    }
    if (isset($data['role'])) {
        $position = $data['position'] ?? $user['position'];
        if ($position === 'Dean' && $data['role'] !== 'manager') {
            throw new Exception('A Dean must use the manager role');
        }
        if (!in_array($data['role'], ['employee', 'manager', 'hr', 'admin'], true)) {
            throw new Exception('Invalid role');
        }
        if ($user['role'] === 'admin' && $data['role'] !== 'admin') {
            $otherAdmins = $db->getRow("SELECT COUNT(*) AS count FROM users WHERE role = 'admin' AND id <> ?", [$id]);
            if ((int) $otherAdmins['count'] === 0) {
                throw new Exception('At least one System Administrator account must remain');
            }
        }
        $updates[] = "role = ?";
        $values[] = $data['role'];
    }
    if (isset($data['is_active'])) {
        $updates[] = "is_active = ?";
        $values[] = $data['is_active'];
    }
    if (isset($data['supervisor_id'])) {
        $department = $data['department'] ?? $user['department'];
        $position = $data['position'] ?? $user['position'];
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
    $sql = "UPDATE users SET " . implode(', ', $updates) . " WHERE id = ?";
    $db->execute($sql, $values);

    Auth::auditLog($_SESSION['user_id'], 'update_user', 'user', $id);

    return ['success' => true, 'message' => 'User updated'];
}

function deleteUser($id) {
    global $db;

    if (!$id) throw new Exception('User ID required');

    $user = $db->getRow("SELECT id, role FROM users WHERE id = ?", [$id]);
    if (!$user) throw new Exception('User not found');
    if ($user['role'] === 'admin') throw new Exception('The admin account cannot be deleted');

    $db->execute("DELETE FROM users WHERE id = ?", [$id]);

    $remainingUsers = $db->getRow("SELECT COUNT(*) AS count FROM users WHERE role <> 'admin'");
    if ((int) $remainingUsers['count'] === 0) {
        $db->execute("UPDATE user_id_sequence SET next_id = 2 WHERE id = 1");
        $db->execute("ALTER TABLE users AUTO_INCREMENT = 2");
    }

    Auth::auditLog($_SESSION['user_id'], 'delete_user', 'user', $id);

    return ['success' => true, 'message' => 'User deleted'];
}

function getDeviceChangeRequests() {
    global $db;

    $requests = DeviceChangeRequest::getPendingForAdmin();

    foreach ($requests as &$request) {
        $info = json_decode($request['device_info'], true) ?: [];
        $request['changes'] = DeviceFingerprint::diffAgainstTrusted($request['user_id'], $info);
    }

    return ['success' => true, 'data' => $requests];
}

function resolveDeviceChangeRequest($id, $status, $resolverUser, $webauthnResponse = null) {
    return DeviceChangeRequest::resolve($id, $status, $resolverUser, $webauthnResponse);
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

/**
 * Streams the bulk-upload template. When ext-zip is available we build a real
 * .xlsx with dropdown data validation for gender/department/position/supervisor
 * (sourced live from the database) so admins just pick from lists instead of
 * guessing valid values; otherwise we fall back to a plain sample CSV.
 */
function downloadUserTemplate() {
    global $db;

    require_once __DIR__ . '/../src/auth/UserRegistration.php';
    $deptOptions = UserRegistration::getDepartmentOptions();
    $departments = $deptOptions['departments'];
    $positions = [];
    foreach ($deptOptions['department_positions'] as $deptPositions) {
        foreach ($deptPositions as $position) {
            $positions[$position] = true;
        }
    }
    $positions = array_keys($positions);
    sort($positions);

    $supervisorRows = $db->getResults(
        "SELECT full_name, username FROM users WHERE role IN ('admin', 'hr', 'manager') AND is_active = 1 ORDER BY full_name"
    );
    $supervisors = array_map(function ($s) {
        return $s['full_name'] . ' (' . $s['username'] . ')';
    }, $supervisorRows);

    if (class_exists('ZipArchive')) {
        buildXlsxTemplate($departments, $positions, $supervisors);
    } else {
        buildCsvTemplateFallback();
    }
}

function xmlEscape($value) {
    return htmlspecialchars((string) $value, ENT_QUOTES | ENT_XML1, 'UTF-8');
}

function buildXlsxTemplate($departments, $positions, $supervisors) {
    $genders = ['Male', 'Female'];
    $maxDataRow = 300; // generous row allowance for bulk entry

    $headerCells = ['username', 'email', 'full_name', 'gender', 'department', 'position', 'supervisor'];
    $headerRowXml = '<row r="1">';
    foreach ($headerCells as $i => $label) {
        $col = chr(65 + $i);
        $headerRowXml .= '<c r="' . $col . '1" t="inlineStr" s="1"><is><t>' . xmlEscape($label) . '</t></is></c>';
    }
    $headerRowXml .= '</row>';

    $lastRow = max(count($genders), count($departments), count($positions), count($supervisors)) + 1;
    $listsColumns = ['A' => $genders, 'B' => $departments, 'C' => $positions, 'D' => $supervisors];
    $listsHeaderXml = '<row r="1">'
        . '<c r="A1" t="inlineStr"><is><t>Gender</t></is></c>'
        . '<c r="B1" t="inlineStr"><is><t>Department</t></is></c>'
        . '<c r="C1" t="inlineStr"><is><t>Position</t></is></c>'
        . '<c r="D1" t="inlineStr"><is><t>Supervisor</t></is></c>'
        . '</row>';
    $listsRowsXml = '';
    for ($r = 2; $r <= $lastRow; $r++) {
        $rowXml = '';
        foreach ($listsColumns as $col => $values) {
            $value = $values[$r - 2] ?? null;
            if ($value !== null && $value !== '') {
                $rowXml .= '<c r="' . $col . $r . '" t="inlineStr"><is><t>' . xmlEscape($value) . '</t></is></c>';
            }
        }
        if ($rowXml !== '') {
            $listsRowsXml .= '<row r="' . $r . '">' . $rowXml . '</row>';
        }
    }

    $genderRange = 'Lists!$A$2:$A$' . (count($genders) + 1);
    $deptRange = 'Lists!$B$2:$B$' . (count($departments) + 1);
    $posRange = 'Lists!$C$2:$C$' . (count($positions) + 1);
    $supRange = 'Lists!$D$2:$D$' . (count($supervisors) + 1);

    $sheet1 = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        . '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
        . '<dimension ref="A1:G' . $maxDataRow . '"/>'
        . '<sheetViews><sheetView tabSelected="1" workbookViewId="0"><pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/></sheetView></sheetViews>'
        . '<cols><col min="1" max="7" width="24" customWidth="1"/></cols>'
        . '<sheetData>' . $headerRowXml . '</sheetData>'
        . '<dataValidations count="4">'
        . '<dataValidation type="list" allowBlank="1" showInputMessage="1" showErrorMessage="1" sqref="D2:D' . $maxDataRow . '"><formula1>' . $genderRange . '</formula1></dataValidation>'
        . '<dataValidation type="list" allowBlank="1" showInputMessage="1" showErrorMessage="1" sqref="E2:E' . $maxDataRow . '"><formula1>' . $deptRange . '</formula1></dataValidation>'
        . '<dataValidation type="list" allowBlank="1" showInputMessage="1" showErrorMessage="1" sqref="F2:F' . $maxDataRow . '"><formula1>' . $posRange . '</formula1></dataValidation>'
        . '<dataValidation type="list" allowBlank="1" showInputMessage="1" showErrorMessage="1" sqref="G2:G' . $maxDataRow . '"><formula1>' . $supRange . '</formula1></dataValidation>'
        . '</dataValidations>'
        . '</worksheet>';

    $sheet2 = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        . '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
        . '<dimension ref="A1:D' . $lastRow . '"/>'
        . '<sheetData>' . $listsHeaderXml . $listsRowsXml . '</sheetData>'
        . '</worksheet>';

    $contentTypes = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        . '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        . '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        . '<Default Extension="xml" ContentType="application/xml"/>'
        . '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
        . '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
        . '<Override PartName="/xl/worksheets/sheet2.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
        . '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
        . '</Types>';

    $rootRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        . '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        . '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
        . '</Relationships>';

    $workbookRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        . '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        . '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
        . '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet2.xml"/>'
        . '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
        . '</Relationships>';

    $workbook = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        . '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
        . '<sheets>'
        . '<sheet name="Employees" sheetId="1" r:id="rId1"/>'
        . '<sheet name="Lists" sheetId="2" r:id="rId2" state="hidden"/>'
        . '</sheets>'
        . '</workbook>';

    $styles = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        . '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
        . '<fonts count="2"><font><sz val="11"/><name val="Calibri"/></font><font><b/><sz val="11"/><name val="Calibri"/></font></fonts>'
        . '<fills count="2"><fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill></fills>'
        . '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>'
        . '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
        . '<cellXfs count="2"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/></cellXfs>'
        . '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>'
        . '</styleSheet>';

    $tmpFile = tempnam(sys_get_temp_dir(), 'lsxlsx');
    $zip = new ZipArchive();
    $opened = $zip->open($tmpFile, ZipArchive::CREATE | ZipArchive::OVERWRITE);
    if ($opened !== true) {
        throw new Exception('Failed to build the template file');
    }
    $zip->addFromString('[Content_Types].xml', $contentTypes);
    $zip->addFromString('_rels/.rels', $rootRels);
    $zip->addFromString('xl/workbook.xml', $workbook);
    $zip->addFromString('xl/_rels/workbook.xml.rels', $workbookRels);
    $zip->addFromString('xl/styles.xml', $styles);
    $zip->addFromString('xl/worksheets/sheet1.xml', $sheet1);
    $zip->addFromString('xl/worksheets/sheet2.xml', $sheet2);
    $zip->close();

    header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    header('Content-Disposition: attachment; filename="leavesync_user_upload_template.xlsx"');
    header('Content-Length: ' . filesize($tmpFile));
    readfile($tmpFile);
    unlink($tmpFile);
}

function buildCsvTemplateFallback() {
    $headers = ['username', 'email', 'full_name', 'gender', 'department', 'position', 'supervisor'];
    $sampleRows = [
        ['jdelacruz', 'jdelacruz@g.batstate-u.edu.ph', 'Juan Dela Cruz', 'male', 'CCS', 'Instructor', 'admin'],
        ['mreyes', 'mreyes@g.batstate-u.edu.ph', 'Maria Reyes', 'female', 'ADMIN', 'HR Officer', 'admin'],
    ];

    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename="leavesync_user_upload_template.csv"');
    echo "\xEF\xBB\xBF"; // BOM so Excel opens the UTF-8 file with correct encoding
    $out = fopen('php://output', 'w');
    fputcsv($out, $headers);
    foreach ($sampleRows as $row) {
        fputcsv($out, $row);
    }
    fclose($out);
}
?>
