<?php

class LeavePolicy {
    public static function validate(array $data): array {
        $leaveTypeId = (int) ($data['leave_type_id'] ?? 0);
        $fiscalYear = (int) ($data['fiscal_year'] ?? 0);
        $days = (float) ($data['days_per_year'] ?? 0);
        $threshold = $data['approval_threshold_days'] ?? null;

        if ($leaveTypeId <= 0 || $fiscalYear < 2000 || $days < 0) {
            throw new InvalidArgumentException('Leave type, fiscal year, and a non-negative day allowance are required');
        }
        if ($threshold !== null && $threshold !== '' && (float) $threshold < 0) {
            throw new InvalidArgumentException('Approval threshold cannot be negative');
        }

        return [
            'leave_type_id' => $leaveTypeId,
            'department' => trim((string) ($data['department'] ?? '')) ?: null,
            'gender' => trim((string) ($data['gender'] ?? '')) ?: null,
            'fiscal_year' => $fiscalYear,
            'days_per_year' => $days,
            'approval_threshold_days' => ($threshold === null || $threshold === '') ? null : (float) $threshold,
            'auto_route_role' => trim((string) ($data['auto_route_role'] ?? '')) ?: null,
            'is_active' => empty($data['is_active']) ? 0 : 1,
        ];
    }
}
