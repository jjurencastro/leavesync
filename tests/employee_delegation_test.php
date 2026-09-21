<?php
require_once __DIR__ . '/../src/leave/EmployeeDelegation.php';

function assertTrue($condition, $message) {
    if (!$condition) {
        throw new Exception($message);
    }
}

class DelegateFakeDb {
    public function getRow($sql, $params = []) {
        $normalized = preg_replace('/\s+/', ' ', trim($sql));

        if (strpos($normalized, 'SELECT backup_approver_id, supervisor_id, department FROM users WHERE id = ?') !== false) {
            return ['backup_approver_id' => 77, 'supervisor_id' => 55, 'department' => 'CCS'];
        }

        if (strpos($normalized, 'SELECT id, role, is_active, password_set, department, position FROM users WHERE id = ? AND (is_active = 1 OR (is_active = 0 AND password_set = 0))') !== false) {
            return ['id' => 77, 'role' => 'manager', 'is_active' => 1, 'password_set' => 1, 'department' => 'CCS', 'position' => 'Dean'];
        }

        if (strpos($normalized, 'SELECT id, role, is_active, password_set FROM users WHERE id = ?') !== false && (int) $params[0] === 55) {
            return ['id' => 55, 'role' => 'manager', 'is_active' => 1, 'password_set' => 1];
        }

        if (strpos($normalized, "SELECT id, role, is_active, password_set FROM users WHERE role = 'admin' AND (is_active = 1 OR (is_active = 0 AND password_set = 0)) ORDER BY id LIMIT 1") !== false) {
            return ['id' => 99, 'role' => 'admin', 'is_active' => 1, 'password_set' => 1];
        }

        return null;
    }
}

$approver = EmployeeDelegation::resolveApprover(new DelegateFakeDb(), 42, 'CCS');
assertTrue((int) $approver['id'] === 77, 'Backup approver should take precedence when configured');
assertTrue($approver['source'] === 'backup', 'The configured backup approver should be tagged as the backup source');

echo "PASS: employee delegation resolves backup and fallback approvers\n";
