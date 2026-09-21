<?php

class OversightSummary {
    public static function summarizeRequests(array $requests): array {
        $summary = [
            'total' => count($requests),
            'pending' => 0,
            'pending_hr' => 0,
            'approved' => 0,
            'rejected' => 0,
            'cancelled' => 0,
            'requested_days' => 0.0,
        ];

        foreach ($requests as $request) {
            $status = $request['status'] ?? '';
            if (array_key_exists($status, $summary)) {
                $summary[$status]++;
            }
            if ($status === 'pending') {
                $summary['requested_days'] += (float) ($request['number_of_days'] ?? 0);
                if (($request['hr_status'] ?? '') === 'pending'
                    && in_array($request['supervisor_status'] ?? '', ['approved', 'not_required'], true)) {
                    $summary['pending_hr']++;
                }
            }
        }

        return $summary;
    }

    public static function summarizeUsers(array $users): array {
        $summary = [
            'total' => count($users),
            'active' => 0,
            'pending_activation' => 0,
            'employees' => 0,
            'managers' => 0,
            'hr' => 0,
            'admins' => 0,
        ];

        foreach ($users as $user) {
            if ((int) ($user['is_active'] ?? 0) === 1) {
                $summary['active']++;
            } else {
                $summary['pending_activation']++;
            }

            $role = $user['role'] ?? '';
            $roleKey = $role === 'admin' ? 'admins' : $role . 's';
            if (array_key_exists($roleKey, $summary)) {
                $summary[$roleKey]++;
            }
        }

        return $summary;
    }
}
