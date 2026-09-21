<?php

class EmployeeLeaveLifecycle {
    /**
     * Employees may cancel their own leave requests only while the request is
     * still pending and before any final approval has been recorded.
     */
    public static function canCancelRequest(array $request, array $user): bool {
        if (($user['role'] ?? '') !== 'employee') {
            return false;
        }

        if ((int) ($request['user_id'] ?? 0) !== (int) ($user['id'] ?? 0)) {
            return false;
        }

        return ($request['status'] ?? null) === 'pending';
    }

    /**
     * Returns a small public summary for employee dashboard rendering.
     */
    public static function getRequestSummary(array $request): array {
        return [
            'status' => $request['status'] ?? 'unknown',
            'cancelable' => self::canCancelRequest($request, ['id' => $request['user_id'] ?? 0, 'role' => 'employee']),
            'approval_stage' => $request['approval_stage'] ?? null,
            'supervisor_status' => $request['supervisor_status'] ?? null,
            'hr_status' => $request['hr_status'] ?? null,
        ];
    }
}
