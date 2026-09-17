<?php

class LeaveRequestAccess {

    public static function canView(array $request, array $viewer) {
        if ($viewer['role'] === 'admin' || (int) $request['user_id'] === (int) $viewer['id']) {
            return true;
        }

        if ($viewer['role'] === 'manager') {
            return (int) ($request['assigned_supervisor_id'] ?? 0) === (int) $viewer['id']
                || (int) ($request['requester_supervisor_id'] ?? 0) === (int) $viewer['id']
                || (int) ($request['manager_id'] ?? 0) === (int) $viewer['id'];
        }

        if ($viewer['role'] === 'hr' && $request['supervisor_status'] === 'pending') {
            return (int) ($request['assigned_supervisor_id'] ?? 0) === (int) $viewer['id'];
        }

        if ($viewer['role'] === 'hr') {
            return $request['status'] === 'rejected'
                || in_array($request['supervisor_status'], ['approved', 'not_required'], true);
        }

        return false;
    }
}
?>