<?php

class Permission {
    private const DEFAULTS = [
        'employee' => ['leave.create', 'leave.view_own', 'leave.cancel_own'],
        'manager' => ['leave.approve_team', 'leave.view_team', 'leave.escalate', 'reports.team'],
        'hr' => ['leave.approve_hr', 'users.manage_records', 'reports.hr', 'policy.view'],
        'admin' => ['users.manage', 'users.restore', 'policy.manage', 'settings.manage', 'audit.view', 'reports.admin'],
    ];

    public static function can(array $user, string $permission, $db = null): bool {
        $role = $user['role'] ?? '';
        if ($db) {
            $row = $db->getRow(
                'SELECT granted FROM role_permissions WHERE role = ? AND permission = ?',
                [$role, $permission]
            );
            if ($row !== null) {
                return (bool) $row['granted'];
            }
        }

        return in_array($permission, self::DEFAULTS[$role] ?? [], true);
    }

    public static function defaults(): array {
        return self::DEFAULTS;
    }
}
