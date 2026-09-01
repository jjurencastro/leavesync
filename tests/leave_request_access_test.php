<?php
require_once __DIR__ . '/../src/leave/LeaveRequestAccess.php';

function assertAccess($actual, $expected, $message) {
    if ($actual !== $expected) {
        throw new Exception($message);
    }
}

$pendingRequest = ['user_id' => 10, 'requester_supervisor_id' => 20, 'supervisor_status' => 'pending'];
$hrReadyRequest = ['user_id' => 10, 'requester_supervisor_id' => 20, 'supervisor_status' => 'approved'];

assertAccess(LeaveRequestAccess::canView($pendingRequest, ['id' => 10, 'role' => 'employee']), true, 'Request owners should have access');
assertAccess(LeaveRequestAccess::canView($pendingRequest, ['id' => 20, 'role' => 'manager']), true, 'Assigned supervisors should have access');
assertAccess(LeaveRequestAccess::canView($pendingRequest, ['id' => 21, 'role' => 'manager']), false, 'Other managers must not have access');
assertAccess(LeaveRequestAccess::canView($pendingRequest, ['id' => 30, 'role' => 'hr']), false, 'HR must not access requests before supervisor approval');
assertAccess(LeaveRequestAccess::canView($hrReadyRequest, ['id' => 30, 'role' => 'hr']), true, 'HR should access requests ready for HR review');
assertAccess(LeaveRequestAccess::canView($pendingRequest, ['id' => 40, 'role' => 'admin']), true, 'Administrators should have access');

echo "PASS: leave request detail access follows the approval workflow\n";
?>