<?php
require_once __DIR__ . '/../src/leave/ManagerLeaveQueue.php';

function assertTrue($condition, $message) {
    if (!$condition) {
        throw new Exception($message);
    }
}

$requests = [
    ['full_name' => 'Alex Santos', 'leave_type_name' => 'Vacation Leave', 'status' => 'pending', 'supervisor_status' => 'pending', 'number_of_days' => 3],
    ['full_name' => 'Bea Cruz', 'leave_type_name' => 'Sick Leave', 'status' => 'approved', 'supervisor_status' => 'approved', 'number_of_days' => 1],
    ['full_name' => 'Carlo Reyes', 'leave_type_name' => 'Vacation Leave', 'status' => 'rejected', 'supervisor_status' => 'rejected', 'number_of_days' => 2],
];

assertTrue(count(ManagerLeaveQueue::filter($requests, 'pending')) === 1, 'Pending filter should return pending team requests');
assertTrue(count(ManagerLeaveQueue::filter($requests, 'all', 'bea')) === 1, 'Search should match employee names case-insensitively');
assertTrue(ManagerLeaveQueue::summarize($requests)['pending_approval'] === 1, 'Summary should count requests awaiting manager approval');
assertTrue(ManagerLeaveQueue::summarize($requests)['pending_days'] === 3.0, 'Summary should total pending request days');

echo "PASS: manager leave queue filters, searches, and summarizes team requests\n";
