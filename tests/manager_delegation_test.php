<?php
require_once __DIR__ . '/../src/leave/EmployeeDelegation.php';

function assertTrue($condition, $message) {
    if (!$condition) {
        throw new Exception($message);
    }
}

class ManagerDelegationFakeDb {
    public function getRow($sql, $params = []) {
        $normalized = preg_replace('/\s+/', ' ', trim($sql));
        if (strpos($normalized, 'SELECT backup_approver_id FROM users WHERE id = ?') !== false) {
            return ['backup_approver_id' => 88];
        }
        if (strpos($normalized, 'SELECT id, role, is_active, password_set FROM users') !== false) {
            return ['id' => 88, 'role' => 'manager', 'is_active' => 1, 'password_set' => 1];
        }
        if (strpos($normalized, 'FROM leave_requests') !== false) {
            return null;
        }
        return null;
    }
}

$backup = EmployeeDelegation::resolveSupervisorBackup(new ManagerDelegationFakeDb(), 22, '2026-09-21');
assertTrue($backup['id'] === 88, 'A configured manager backup should be selected');
assertTrue($backup['role'] === 'manager', 'The backup role should be preserved');

echo "PASS: manager backup delegation resolves an active fallback approver\n";