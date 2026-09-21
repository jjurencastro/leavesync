<?php

class ManagerLeaveQueue {
    public static function normalizeStatus(string $status): string {
        $allowed = ['all', 'pending', 'approved', 'rejected', 'cancelled'];
        $status = strtolower(trim($status));
        return in_array($status, $allowed, true) ? $status : 'all';
    }

    public static function filter(array $requests, string $status = 'all', string $search = ''): array {
        $status = self::normalizeStatus($status);
        $search = strtolower(trim($search));

        return array_values(array_filter($requests, function ($request) use ($status, $search) {
            if ($status !== 'all' && ($request['status'] ?? '') !== $status) {
                return false;
            }

            if ($search === '') {
                return true;
            }

            $haystack = strtolower(implode(' ', [
                $request['full_name'] ?? '',
                $request['leave_type_name'] ?? '',
                $request['reason'] ?? '',
            ]));

            return strpos($haystack, $search) !== false;
        }));
    }

    public static function summarize(array $requests): array {
        $summary = [
            'total' => count($requests),
            'pending_approval' => 0,
            'approved' => 0,
            'rejected' => 0,
            'cancelled' => 0,
            'pending_days' => 0.0,
        ];

        foreach ($requests as $request) {
            $status = $request['status'] ?? '';
            if ($status === 'pending' && ($request['supervisor_status'] ?? '') === 'pending') {
                $summary['pending_approval']++;
            }
            if (array_key_exists($status, $summary)) {
                $summary[$status]++;
            }
            if ($status === 'pending') {
                $summary['pending_days'] += (float) ($request['number_of_days'] ?? 0);
            }
        }

        return $summary;
    }
}
