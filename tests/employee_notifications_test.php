<?php
require_once __DIR__ . '/../src/leave/EmployeeNotifications.php';

function assertTrue($condition, $message) {
    if (!$condition) {
        throw new Exception($message);
    }
}

$notifications = [
    ['id' => 1, 'title' => 'Leave Request Approved', 'is_read' => 0, 'created_at' => '2026-09-21 08:00:00'],
    ['id' => 2, 'title' => 'Account activated', 'is_read' => 1, 'created_at' => '2026-09-21 07:00:00'],
    ['id' => 3, 'title' => 'Password changed', 'is_read' => 0, 'created_at' => '2026-09-21 06:00:00'],
];

assertTrue(EmployeeNotifications::getUnreadCount($notifications) === 2, 'Unread count should count only unread notifications');
assertTrue(EmployeeNotifications::formatNotification($notifications[0])['title'] === 'Leave Request Approved', 'Notification formatting should preserve the title');
assertTrue(EmployeeNotifications::formatNotification($notifications[0])['read_state'] === 'unread', 'Unread notifications should be labeled as unread');
assertTrue(EmployeeNotifications::summarize($notifications)['latest_title'] === 'Leave Request Approved', 'Summary should reflect the newest notification');

echo "PASS: employee notifications summary and unread tracking work\n";
