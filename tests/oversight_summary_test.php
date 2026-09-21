<?php
require_once __DIR__ . '/../src/oversight/OversightSummary.php';

function assertTrue($condition, $message) {
    if (!$condition) {
        throw new Exception($message);
    }
}

$requestSummary = OversightSummary::summarizeRequests([
    ['status' => 'pending', 'supervisor_status' => 'approved', 'hr_status' => 'pending', 'number_of_days' => 4],
    ['status' => 'approved', 'supervisor_status' => 'approved', 'hr_status' => 'approved', 'number_of_days' => 2],
    ['status' => 'rejected', 'supervisor_status' => 'rejected', 'hr_status' => 'rejected', 'number_of_days' => 1],
]);
assertTrue($requestSummary['pending_hr'] === 1, 'Summary should identify requests awaiting HR approval');
assertTrue($requestSummary['requested_days'] === 4.0, 'Summary should total pending requested days');

$userSummary = OversightSummary::summarizeUsers([
    ['role' => 'employee', 'is_active' => 1],
    ['role' => 'manager', 'is_active' => 1],
    ['role' => 'hr', 'is_active' => 0],
    ['role' => 'admin', 'is_active' => 1],
]);
assertTrue($userSummary['active'] === 3, 'User summary should count active accounts');
assertTrue($userSummary['pending_activation'] === 1, 'User summary should count pending activations');
assertTrue($userSummary['managers'] === 1 && $userSummary['admins'] === 1, 'User summary should count role totals');

echo "PASS: HR and admin oversight summaries aggregate complete operational counts\n";
