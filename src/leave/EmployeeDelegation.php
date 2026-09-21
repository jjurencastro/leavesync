<?php

class EmployeeDelegation {
    /**
     * Returns a qualified fallback approver if the employee has configured one,
     * or a department fallback if no specific backup approver is defined.
     */
    public static function resolveApprover($db, $employeeId, $department = null) {
        $employee = $db->getRow(
            "SELECT backup_approver_id, supervisor_id, department FROM users WHERE id = ?",
            [$employeeId]
        );
        if (!$employee) {
            return null;
        }

        if (!empty($employee['backup_approver_id'])) {
            $backup = $db->getRow(
                "SELECT id, role, is_active, password_set, department, position
                 FROM users WHERE id = ? AND (is_active = 1 OR (is_active = 0 AND password_set = 0))",
                [$employee['backup_approver_id']]
            );
            if ($backup) {
                return ['id' => (int) $backup['id'], 'role' => $backup['role'] ?? 'manager', 'source' => 'backup'];
            }
        }

        $supervisorId = (int) ($employee['supervisor_id'] ?? 0);
        if ($supervisorId > 0) {
            $supervisor = $db->getRow(
                "SELECT id, role, is_active, password_set FROM users WHERE id = ?",
                [$supervisorId]
            );
            if ($supervisor && ((int) $supervisor['is_active'] === 1 || ((int) $supervisor['is_active'] === 0 && (int) ($supervisor['password_set'] ?? 0) === 0))) {
                return ['id' => (int) $supervisor['id'], 'role' => $supervisor['role'] ?? 'manager', 'source' => 'supervisor'];
            }
        }

        if (!empty($department) && $department !== 'ADMIN') {
            $departmentDean = $db->getRow(
                "SELECT id, role, is_active, password_set
                 FROM users
                 WHERE department = ? AND (position = 'Dean' OR role = 'manager') AND (is_active = 1 OR (is_active = 0 AND password_set = 0))
                 LIMIT 1",
                [$department]
            );
            if ($departmentDean) {
                return ['id' => (int) $departmentDean['id'], 'role' => 'manager', 'source' => 'department'];
            }
        }

        $admin = $db->getRow(
            "SELECT id, role, is_active, password_set FROM users WHERE role = 'admin' AND (is_active = 1 OR (is_active = 0 AND password_set = 0)) ORDER BY id LIMIT 1",
            []
        );
        if ($admin) {
            return ['id' => (int) $admin['id'], 'role' => $admin['role'] ?? 'admin', 'source' => 'admin'];
        }

        return null;
    }
}
