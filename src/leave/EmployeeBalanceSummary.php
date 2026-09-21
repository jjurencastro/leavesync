<?php

class EmployeeBalanceSummary {
    public static function summarize(array $balances): array {
        $summary = [
            'available' => 0.0,
            'pending' => 0.0,
            'used' => 0.0,
            'items' => [],
        ];

        foreach ($balances as $balance) {
            $name = $balance['leave_type_name'] ?? $balance['name'] ?? 'Leave';
            $available = (float) ($balance['balance'] ?? 0);
            $pending = (float) ($balance['pending_days'] ?? 0);
            $used = (float) ($balance['used_days'] ?? 0);

            $summary['available'] += $available;
            $summary['pending'] += $pending;
            $summary['used'] += $used;
            $summary['items'][] = [
                'leave_type_name' => $name,
                'available' => $available,
                'pending' => $pending,
                'used' => $used,
                'total' => (float) ($balance['total_days'] ?? ($available + $pending + $used)),
            ];
        }

        return $summary;
    }
}
