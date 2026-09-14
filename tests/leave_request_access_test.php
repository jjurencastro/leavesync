<?php
require_once __DIR__ . '/../src/leave/LeaveRequestAccess.php';
require_once __DIR__ . '/../src/leave/ApprovalChain.php';

function assertAccess($actual, $expected, $message) {
    if ($actual !== $expected) {
        throw new Exception($message);
    }
}

class ApprovalChainFakeDb {
    private function normalizeSql($sql) {
        return preg_replace('/\s+/', ' ', trim($sql));
    }

    public function getRow($sql, $params = []) {
        $normalized = $this->normalizeSql($sql);

        if ($normalized === 'SELECT supervisor_id FROM users WHERE id = ?') {
            $userId = (int) $params[0];
            $map = [10 => 20, 20 => 30, 30 => 40];
            return ['supervisor_id' => isset($map[$userId]) ? $map[$userId] : null];
        }

        if ($normalized === 'SELECT id, supervisor_id, role, is_active FROM users WHERE id = ?') {
            $userId = (int) $params[0];
            $map = [
                20 => ['id' => 20, 'supervisor_id' => 30, 'role' => 'manager', 'is_active' => 1],
                30 => ['id' => 30, 'supervisor_id' => 40, 'role' => 'hr', 'is_active' => 1],
                40 => ['id' => 40, 'supervisor_id' => null, 'role' => 'admin', 'is_active' => 1],
            ];
            return isset($map[$userId]) ? $map[$userId] : null;
        }

        if ($normalized === "SELECT id FROM leave_requests WHERE user_id = ? AND status = 'approved' AND start_date <= ? AND end_date >= ? LIMIT 1") {
            if ((int) $params[0] === 20) {
                return ['id' => 99];
            }
            return null;
        }

        return null;
    }

    public function getResults($sql, $params = []) {
        $normalized = $this->normalizeSql($sql);
        if ($normalized === "SELECT id, role FROM users WHERE role = 'admin' AND is_active = 1 ORDER BY id") {
            return [['id' => 40, 'role' => 'admin']];
        }

        return [];
    }
}

$pendingRequest = ['user_id' => 10, 'requester_supervisor_id' => 20, 'assigned_supervisor_id' => 20, 'supervisor_status' => 'pending'];
$hrReadyRequest = ['user_id' => 10, 'requester_supervisor_id' => 20, 'assigned_supervisor_id' => 30, 'supervisor_status' => 'approved'];
$hrAssignedRequest = ['user_id' => 10, 'assigned_supervisor_id' => 30, 'supervisor_status' => 'pending'];

assertAccess(LeaveRequestAccess::canView($pendingRequest, ['id' => 10, 'role' => 'employee']), true, 'Request owners should have access');
assertAccess(LeaveRequestAccess::canView($pendingRequest, ['id' => 20, 'role' => 'manager']), true, 'Assigned supervisors should have access');
assertAccess(LeaveRequestAccess::canView($pendingRequest, ['id' => 21, 'role' => 'manager']), false, 'Other managers must not have access');
assertAccess(LeaveRequestAccess::canView($pendingRequest, ['id' => 30, 'role' => 'hr']), false, 'HR must not access requests before supervisor approval');
assertAccess(LeaveRequestAccess::canView($hrReadyRequest, ['id' => 30, 'role' => 'hr']), true, 'HR should access requests ready for HR review');
assertAccess(LeaveRequestAccess::canView($pendingRequest, ['id' => 40, 'role' => 'admin']), true, 'Administrators should have access');
assertAccess(LeaveRequestAccess::canView($hrAssignedRequest, ['id' => 30, 'role' => 'hr']), true, 'Assigned HR supervisors should have access');

$chainResult = ApprovalChain::resolveFirstAvailable(new ApprovalChainFakeDb(), 10, '2026-09-11');
assertAccess($chainResult['id'], 30, 'Supervisor on approved leave should be skipped and the next available supervisor selected');
assertAccess($chainResult['bypassed_ids'][0], 20, 'The unavailable supervisor should be recorded as bypassed');

echo "PASS: leave request detail access follows the approval workflow and the supervisor chain skips approved-leave approvers\n";
?>