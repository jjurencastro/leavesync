<?php
require_once __DIR__ . '/../src/security/Permission.php';
require_once __DIR__ . '/../src/leave/LeavePolicy.php';

function assertTrue($condition, $message) {
    if (!$condition) {
        throw new Exception($message);
    }
}

assertTrue(Permission::can(['role' => 'manager'], 'leave.approve_team'), 'Managers should have team approval permission by default');
assertTrue(!Permission::can(['role' => 'employee'], 'leave.approve_team'), 'Employees should not have team approval permission');

$policy = LeavePolicy::validate([
    'leave_type_id' => 1,
    'fiscal_year' => 2026,
    'days_per_year' => 15,
    'approval_threshold_days' => 5,
    'auto_route_role' => 'manager',
    'is_active' => 1,
]);
assertTrue($policy['days_per_year'] === 15.0, 'Policy validation should normalize day allowances');
assertTrue($policy['approval_threshold_days'] === 5.0, 'Policy validation should preserve approval thresholds');

$failed = false;
try {
    LeavePolicy::validate(['leave_type_id' => 1, 'fiscal_year' => 2026, 'days_per_year' => -1]);
} catch (InvalidArgumentException $e) {
    $failed = true;
}
assertTrue($failed, 'Negative policy allowances must be rejected');

echo "PASS: permission and leave policy foundations validate safely\n";
