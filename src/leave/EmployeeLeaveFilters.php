<?php

class EmployeeLeaveFilters {
    public static function normalizeStatus(string $status): string {
        $allowed = ['all', 'pending', 'approved', 'rejected', 'cancelled'];
        $status = strtolower(trim((string) $status));
        return in_array($status, $allowed, true) ? $status : 'all';
    }

    public static function apply(array $requests, string $status): array {
        $filter = self::normalizeStatus($status);
        if ($filter === 'all') {
            return $requests;
        }

        return array_values(array_filter($requests, function ($request) use ($filter) {
            return ($request['status'] ?? '') === $filter;
        }));
    }
}
