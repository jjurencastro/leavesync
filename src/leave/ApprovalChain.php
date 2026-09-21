<?php

class ApprovalChain {

    public static function resolveFirstAvailable($db, $requesterId, $filedDate) {
        $requester = $db->getRow(
            "SELECT id, supervisor_id, backup_approver_id, department, position FROM users WHERE id = ?",
            [$requesterId]
        );

        $delegated = EmployeeDelegation::resolveApprover($db, $requesterId, $requester['department'] ?? null);
        if ($delegated && !empty($delegated['id'])) {
            return [
                'id' => (int) $delegated['id'],
                'role' => $delegated['role'] ?? 'manager',
                'bypassed_ids' => [],
                'source' => $delegated['source'] ?? 'delegated'
            ];
        }

        $candidateId = (int) ($requester['supervisor_id'] ?? 0);
        $visited = [(int) $requesterId => true];
        $bypassed = [];

        while ($candidateId > 0 && !isset($visited[$candidateId])) {
            $visited[$candidateId] = true;
            $candidate = $db->getRow(
                "SELECT id, supervisor_id, role, position, department, is_active, password_set
                 FROM users
                 WHERE id = ?",
                [$candidateId]
            );

            if (!$candidate) {
                break;
            }

            // An assigned supervisor with position 'Dean' or role in manager/hr/admin is eligible
            $isSupervisorRole = in_array($candidate['role'], ['manager', 'hr', 'admin'], true)
                || ($candidate['position'] ?? '') === 'Dean'
                || $candidateId === (int) ($requester['supervisor_id'] ?? 0);

            if ($isSupervisorRole) {
                $isCandidateActive = (int) $candidate['is_active'] === 1 || ((int) $candidate['is_active'] === 0 && (int) ($candidate['password_set'] ?? 0) === 0);
                if ($isCandidateActive && !self::hasApprovedLeave($db, $candidate['id'], $filedDate)) {
                    $effectiveRole = ($candidate['role'] === 'admin' || $candidate['role'] === 'hr') ? $candidate['role'] : 'manager';
                    return [
                        'id' => (int) $candidate['id'],
                        'role' => $effectiveRole,
                        'bypassed_ids' => $bypassed
                    ];
                }

                $bypassed[] = (int) $candidate['id'];
            }

            $candidateId = (int) ($candidate['supervisor_id'] ?? 0);
        }

        // Fallback: if no direct supervisor was found, find active Dean for the requester's department if academic
        if (!empty($requester['department']) && $requester['department'] !== 'ADMIN') {
            $departmentDean = $db->getRow(
                "SELECT id, role, position, is_active, password_set
                 FROM users
                 WHERE department = ? AND (position = 'Dean' OR role = 'manager') AND (is_active = 1 OR (is_active = 0 AND password_set = 0))
                 LIMIT 1",
                [$requester['department']]
            );
            if ($departmentDean && !isset($visited[(int) $departmentDean['id']]) && !self::hasApprovedLeave($db, $departmentDean['id'], $filedDate)) {
                return [
                    'id' => (int) $departmentDean['id'],
                    'role' => 'manager',
                    'bypassed_ids' => $bypassed
                ];
            }
        }

        $admins = $db->getResults(
            "SELECT id, role, is_active, password_set
             FROM users
             WHERE role = 'admin' AND (is_active = 1 OR (is_active = 0 AND password_set = 0))
             ORDER BY id",
            []
        );

        foreach ($admins as $admin) {
            if (!isset($visited[(int) $admin['id']]) && !self::hasApprovedLeave($db, $admin['id'], $filedDate)) {
                return [
                    'id' => (int) $admin['id'],
                    'role' => $admin['role'],
                    'bypassed_ids' => $bypassed
                ];
            }
        }

        return null;
    }

    private static function hasApprovedLeave($db, $userId, $filedDate) {
        return (bool) $db->getRow(
            "SELECT id
             FROM leave_requests
             WHERE user_id = ?
               AND status = 'approved'
               AND start_date <= ?
               AND end_date >= ?
             LIMIT 1",
            [$userId, $filedDate, $filedDate]
        );
    }
}