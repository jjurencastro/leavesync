<?php
require_once __DIR__ . '/../src/auth/UserRegistration.php';

class FakeRegistrationDb {
    public function getRow($sql, $params = []) {
        $normalized = preg_replace('/\s+/', ' ', trim($sql));
        if ($normalized === "SELECT id, username, email, full_name, role, department FROM users WHERE LOWER(email) = LOWER(?) OR LOWER(username) = LOWER(?)") {
            $identifier = strtolower($params[0]);
            if ($identifier === 'admin' || $identifier === 'admin@g.batstate-u.edu.ph') {
                return ['id' => 1, 'username' => 'admin', 'email' => 'admin@g.batstate-u.edu.ph', 'full_name' => 'System Admin', 'role' => 'admin', 'department' => 'ADMIN'];
            }
            if ($identifier === 'dean_ccs' || $identifier === 'dean_ccs@g.batstate-u.edu.ph') {
                return ['id' => 2, 'username' => 'dean_ccs', 'email' => 'dean_ccs@g.batstate-u.edu.ph', 'full_name' => 'Dean CCS', 'role' => 'manager', 'department' => 'CCS'];
            }
            if ($identifier === 'hr_head' || $identifier === 'hr@g.batstate-u.edu.ph') {
                return ['id' => 3, 'username' => 'hr_head', 'email' => 'hr@g.batstate-u.edu.ph', 'full_name' => 'HR Head', 'role' => 'hr', 'department' => 'ADMIN'];
            }
            return null;
        }

        if ($normalized === "SELECT id FROM users WHERE id = ? AND id <> ? AND (is_active = 1 OR (is_active = 0 AND password_set = 0)) AND role IN ('admin', 'hr', 'manager')") {
            $supervisorId = (int)$params[0];
            if (in_array($supervisorId, [1, 2, 3, 4], true) && $supervisorId !== (int)$params[1]) {
                return ['id' => $supervisorId];
            }
            return null;
        }

        // Reporting lines for the loop check: user 4 (a manager) reports to user 5
        if ($normalized === "SELECT supervisor_id FROM users WHERE id = ?") {
            $reportsTo = [4 => 5, 5 => 1];
            return isset($reportsTo[(int)$params[0]]) ? ['supervisor_id' => $reportsTo[(int)$params[0]]] : null;
        }

        return null;
    }
}

$fakeDb = new FakeRegistrationDb();

// Test admin supervisor resolution
$adminSupervisor = UserRegistration::resolveEligibleSupervisor('admin', 0, 'ADMIN', 'HR Officer', $fakeDb);
if (!$adminSupervisor || $adminSupervisor['role'] !== 'admin') {
    fwrite(STDERR, "FAIL: Expected admin supervisor to resolve for ADMIN department" . PHP_EOL);
    exit(1);
}

// Test cross-department supervisors: a CCS dean can supervise a CTE instructor and a BED teacher
foreach ([['CTE', 'Instructor'], ['BED', 'Teacher'], ['ADMIN', 'Staff']] as [$dept, $pos]) {
    $crossDept = UserRegistration::resolveEligibleSupervisor('dean_ccs', 0, $dept, $pos, $fakeDb);
    if (!$crossDept || (int)$crossDept['id'] !== 2) {
        fwrite(STDERR, "FAIL: Expected any active supervisor to be eligible for $dept $pos" . PHP_EOL);
        exit(1);
    }
}

// HR may supervise non-Dean staff, and an admin may supervise academic staff
if (!UserRegistration::isEligibleSupervisor(3, 0, 'CCS', 'Instructor', $fakeDb) || !UserRegistration::isEligibleSupervisor(1, 0, 'CCS', 'Instructor', $fakeDb)) {
    fwrite(STDERR, "FAIL: Expected HR and admin to be eligible supervisors for academic staff" . PHP_EOL);
    exit(1);
}

// Non-supervisors, unknown users and the user themselves are never eligible
if (UserRegistration::isEligibleSupervisor(99, 0, 'CCS', 'Instructor', $fakeDb) || UserRegistration::isEligibleSupervisor(2, 2, 'CCS', 'Instructor', $fakeDb)) {
    fwrite(STDERR, "FAIL: Expected unknown users and self to be rejected as supervisor" . PHP_EOL);
    exit(1);
}

// Reporting loops are rejected: user 4 reports to 5, so 4 cannot become 5's supervisor
if (UserRegistration::isEligibleSupervisor(4, 5, 'CCS', 'Instructor', $fakeDb)) {
    fwrite(STDERR, "FAIL: Expected a supervisor who reports to the user to be rejected" . PHP_EOL);
    exit(1);
}

// BED department positions
if (!UserRegistration::isValidDepartmentPosition('BED', 'Principal')
    || UserRegistration::getDefaultRoleForPosition('BED', 'Principal') !== 'manager'
    || UserRegistration::getDefaultRoleForPosition('BED', 'Teacher') !== 'employee'
    || !in_array('Principal', UserRegistration::getDepartmentOptions()['department_positions']['BED'], true)) {
    fwrite(STDERR, "FAIL: Expected BED department with a manager-level Principal" . PHP_EOL);
    exit(1);
}

// Test academic supervisor resolution (Dean for Instructor)
$deanSupervisor = UserRegistration::resolveEligibleSupervisor('dean_ccs@g.batstate-u.edu.ph', 0, 'CCS', 'Instructor', $fakeDb);
if (!$deanSupervisor || (int)$deanSupervisor['id'] !== 2) {
    fwrite(STDERR, "FAIL: Expected Dean CCS to resolve as supervisor for CCS Instructor" . PHP_EOL);
    exit(1);
}

// Test HR supervisor resolution for Dean
$hrSupervisor = UserRegistration::resolveEligibleSupervisor('hr@g.batstate-u.edu.ph', 0, 'CCS', 'Dean', $fakeDb);
if (!$hrSupervisor || (int)$hrSupervisor['id'] !== 3) {
    fwrite(STDERR, "FAIL: Expected HR Head to resolve as supervisor for CCS Dean" . PHP_EOL);
    exit(1);
}

// Test listed and custom position validity
if (!UserRegistration::isValidDepartmentPosition('CCS', 'Instructor')) {
    fwrite(STDERR, "FAIL: Expected CCS Instructor to be valid" . PHP_EOL);
    exit(1);
}

if (!UserRegistration::isValidDepartmentPosition('CCS', 'Program Coordinator')) {
    fwrite(STDERR, "FAIL: Expected a custom CCS position to be valid" . PHP_EOL);
    exit(1);
}

if (UserRegistration::isValidDepartmentPosition('UNKNOWN', 'Program Coordinator')
    || UserRegistration::isValidDepartmentPosition('CCS', '')
    || UserRegistration::isValidDepartmentPosition('CCS', str_repeat('x', 51))) {
    fwrite(STDERR, "FAIL: Expected an unknown department, empty title, or overlong title to be invalid" . PHP_EOL);
    exit(1);
}

if (UserRegistration::getDefaultRoleForPosition('CCS', 'Program Coordinator') !== 'employee'
    || UserRegistration::getDefaultRoleForPosition('CCS', 'HR Officer') !== 'employee'
    || UserRegistration::getDefaultRoleForPosition('CCS', 'Dean') !== 'manager'
    || UserRegistration::getDefaultRoleForPosition('ADMIN', 'HR Officer') !== 'hr') {
    fwrite(STDERR, "FAIL: Expected custom positions to default to employee without changing listed role defaults" . PHP_EOL);
    exit(1);
}

$customPositionSupervisor = UserRegistration::resolveEligibleSupervisor('dean_ccs', 0, 'CCS', 'Program Coordinator', $fakeDb);
if (!$customPositionSupervisor || (int)$customPositionSupervisor['id'] !== 2) {
    fwrite(STDERR, "FAIL: Expected a custom CCS position to resolve its department manager as supervisor" . PHP_EOL);
    exit(1);
}

echo "PASS: bulk user validation and supervisor resolution tests pass\n";
