<?php

/**
 * Single definition of "a leave request is waiting on this user", shared by the
 * sidebar approval badge and the bell notifications so the two never disagree.
 */
class ApprovalQueue {
    /**
     * SQL condition (aliases: lr = leave_requests, req = the requester's users row)
     * and its parameters for requests currently awaiting an action from $user.
     * @return array [string $sql, array $params]
     */
    public static function waitingOnCondition(array $user): array {
        $id = (int) ($user['id'] ?? 0);
        $role = $user['role'] ?? '';

        $sql = "(lr.status = 'pending' AND (
            (lr.supervisor_status = 'pending' AND (
                lr.assigned_supervisor_id = ?
                OR (lr.assigned_supervisor_id IS NULL AND req.supervisor_id = ?)
                " . ($role === 'admin' ? "OR (lr.assigned_supervisor_id IS NULL AND req.supervisor_id IS NULL)" : '') . "
                " . ($role === 'manager' ? "OR (lr.assigned_supervisor_id IS NULL AND req.supervisor_id IS NULL AND req.department = ?)" : '') . "
            ))";
        $params = [$id, $id];
        if ($role === 'manager') {
            $params[] = $user['department'] ?? '';
        }

        if (in_array($role, ['hr', 'admin'], true)) {
            $sql .= " OR (lr.supervisor_status IN ('approved', 'not_required') AND lr.hr_status = 'pending')";
        }

        return [$sql . "))", $params];
    }
}
