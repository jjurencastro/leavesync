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

        if ($normalized === "SELECT id FROM users WHERE id = ? AND id <> ? AND (is_active = 1 OR (is_active = 0 AND password_set = 0)) AND role = 'manager' AND department = ?") {
            if ((int)$params[0] === 2 && (int)$params[1] === 0 && $params[2] === 'CCS') {
                return ['id' => 2];
            }
            return null;
        }

        if ($normalized === "SELECT id FROM users WHERE id = ? AND id <> ? AND (is_active = 1 OR (is_active = 0 AND password_set = 0)) AND role = 'hr'") {
            if ((int)$params[0] === 3 && (int)$params[1] === 0) {
                return ['id' => 3];
            }
            return null;
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

// Test department-position validity
if (!UserRegistration::isValidDepartmentPosition('CCS', 'Instructor')) {
    fwrite(STDERR, "FAIL: Expected CCS Instructor to be valid" . PHP_EOL);
    exit(1);
}

if (UserRegistration::isValidDepartmentPosition('CCS', 'HR Officer')) {
    fwrite(STDERR, "FAIL: Expected CCS HR Officer to be invalid" . PHP_EOL);
    exit(1);
}

echo "PASS: bulk user validation and supervisor resolution tests pass\n";

