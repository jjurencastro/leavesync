<?php

class ApprovalChain {

    public static function resolveFirstAvailable($db, $requesterId, $filedDate) {
        $requester = $db->getRow(
            "SELECT supervisor_id FROM users WHERE id = ?",
            [$requesterId]
        );

        $candidateId = (int) ($requester['supervisor_id'] ?? 0);
        $visited = [];
        $bypassed = [];

        while ($candidateId > 0 && !isset($visited[$candidateId])) {
            $visited[$candidateId] = true;
            $candidate = $db->getRow(
                "SELECT id, supervisor_id, role, is_active
                 FROM users
                 WHERE id = ?",
                [$candidateId]
            );

            if (!$candidate) {
                break;
            }

            if (in_array($candidate['role'], ['manager', 'hr', 'admin'], true)) {
                if ((int) $candidate['is_active'] === 1 && !self::hasApprovedLeave($db, $candidate['id'], $filedDate)) {
                    return [
                        'id' => (int) $candidate['id'],
                        'role' => $candidate['role'],
                        'bypassed_ids' => $bypassed
                    ];
                }

                $bypassed[] = (int) $candidate['id'];
            }

            $candidateId = (int) ($candidate['supervisor_id'] ?? 0);
        }

        $admins = $db->getResults(
            "SELECT id, role
             FROM users
             WHERE role = 'admin' AND is_active = 1
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