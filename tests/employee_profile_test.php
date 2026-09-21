<?php
require_once __DIR__ . '/../src/leave/EmployeeProfile.php';

function assertTrue($condition, $message) {
    if (!$condition) {
        throw new Exception($message);
    }
}

$user = ['id' => 42, 'role' => 'employee'];
assertTrue(EmployeeProfile::canEditProfile($user, 'full_name'), 'Employee should be allowed to edit their full name');
assertTrue(!EmployeeProfile::canEditProfile($user, 'password_hash'), 'Sensitive fields should be blocked');

$updated = EmployeeProfile::sanitizeProfileUpdate([
    'full_name' => '  Jane Doe  ',
    'gender' => 'female',
    'department' => 'CCS',
    'position' => 'Instructor',
    'password_hash' => 'secret'
]);

assertTrue($updated['full_name'] === 'Jane Doe', 'Profile sanitization should trim full name');
assertTrue(!isset($updated['password_hash']), 'Sensitive fields should be removed from sanitization');

echo "PASS: employee profile self-service rules work\n";
