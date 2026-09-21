<?php
require_once __DIR__ . '/../src/leave/EmployeeBalanceSummary.php';

function assertTrue($condition, $message) {
    if (!$condition) {
        throw new Exception($message);
    }
}

$balances = [
    ['leave_type_name' => 'Vacation Leave', 'balance' => 10.0, 'pending_days' => 2.0, 'used_days' => 3.0, 'total_days' => 15.0],
    ['leave_type_name' => 'Sick Leave', 'balance' => 5.0, 'pending_days' => 1.0, 'used_days' => 2.0, 'total_days' => 8.0],
];

$summary = EmployeeBalanceSummary::summarize($balances);
assertTrue($summary['available'] === 15.0, 'Available balance should aggregate across leave types');
assertTrue($summary['pending'] === 3.0, 'Pending balance should aggregate across leave types');
assertTrue($summary['used'] === 5.0, 'Used days should aggregate across leave types');
assertTrue($summary['items'][0]['leave_type_name'] === 'Vacation Leave', 'Balance summary should preserve the leave type names');

echo "PASS: employee leave balance summary aggregates available, pending, and used totals\n";
