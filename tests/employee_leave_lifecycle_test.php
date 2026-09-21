<?php
require_once __DIR__ . '/../src/leave/EmployeeLeaveLifecycle.php';

function assertTrue($condition, $message) {
    if (!$condition) {
        throw new Exception($message);
    }
}

$request = [
    'id' => 101,
    'user_id' => 42,
    'status' => 'pending',
    'supervisor_status' => 'pending',
    'hr_status' => 'pending',
];
$user = ['id' => 42, 'role' => 'employee'];

assertTrue(EmployeeLeaveLifecycle::canCancelRequest($request, $user), 'Employees should be able to cancel their own pending leave requests');
assertTrue(!EmployeeLeaveLifecycle::canCancelRequest(['id' => 102, 'user_id' => 99, 'status' => 'pending'], $user), 'Employees should not cancel other users\' requests');
assertTrue(!EmployeeLeaveLifecycle::canCancelRequest(['id' => 103, 'user_id' => 42, 'status' => 'approved'], $user), 'Approved leave requests should not be cancelable');

$cancelled = EmployeeLeaveLifecycle::getRequestSummary($request);
assertTrue(($cancelled['status'] ?? '') === 'pending', 'Pending request summary should reflect the active state');

echo "PASS: employee leave lifecycle supports self-service cancellation checks\n";
