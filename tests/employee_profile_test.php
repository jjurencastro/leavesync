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

[$d, $e] = EmployeeProfile::sanitizeProfileDetails([
    'nickname' => ' JD ', 'contact_number' => '+63 912-345-6789', 'address' => '',
    'date_of_birth' => '1990-05-20', 'civil_status' => 'Married',
    'emergency_contact_name' => 'Maria Dela Cruz', 'emergency_contact_number' => '09171234567',
    'is_admin' => 1,
]);
assertTrue($e === [], 'Valid details should have no errors');
assertTrue($d['nickname'] === 'JD' && $d['address'] === null, 'Details should trim and null blanks');
assertTrue($d['civil_status'] === 'married', 'Civil status should be normalised');
assertTrue(!isset($d['is_admin']), 'Unknown detail fields should be dropped');

foreach ([['contact_number' => 'abc'], ['contact_number' => '123'], ['date_of_birth' => '2999-01-01'],
          ['date_of_birth' => '1990-02-31'], ['civil_status' => 'unknown'], ['address' => str_repeat('x', 300)]] as $bad) {
    assertTrue(count(EmployeeProfile::sanitizeProfileDetails($bad)[1]) === 1, 'Invalid detail should be rejected: ' . json_encode($bad));
}

echo "PASS: employee profile self-service rules work\n";
