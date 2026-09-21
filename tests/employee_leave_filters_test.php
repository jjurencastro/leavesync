<?php
require_once __DIR__ . '/../src/leave/EmployeeLeaveFilters.php';

function assertTrue($condition, $message) {
    if (!$condition) {
        throw new Exception($message);
    }
}

$requests = [
    ['id' => 1, 'status' => 'pending'],
    ['id' => 2, 'status' => 'approved'],
    ['id' => 3, 'status' => 'rejected'],
    ['id' => 4, 'status' => 'cancelled'],
];

assertTrue(EmployeeLeaveFilters::normalizeStatus('PENDING') === 'pending', 'Status normalization should accept mixed case');
assertTrue(count(EmployeeLeaveFilters::apply($requests, 'approved')) === 1, 'Approved filter should keep only approved requests');
assertTrue(count(EmployeeLeaveFilters::apply($requests, 'all')) === 4, 'All filter should return the full request list');

echo "PASS: employee leave request filters handle status filtering\n";
