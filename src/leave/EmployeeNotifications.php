<?php

class EmployeeNotifications {
    public static function getUnreadCount(array $notifications): int {
        return count(array_filter($notifications, function ($item) {
            return !empty($item['is_read']) ? false : true;
        }));
    }

    public static function formatNotification(array $notification): array {
        return [
            'id' => $notification['id'] ?? null,
            'title' => $notification['title'] ?? 'Notification',
            'message' => $notification['message'] ?? '',
            'created_at' => $notification['created_at'] ?? null,
            'read_state' => !empty($notification['is_read']) ? 'read' : 'unread',
            'notification_type' => $notification['notification_type'] ?? 'info',
        ];
    }

    public static function summarize(array $notifications): array {
        $formatted = array_map([self::class, 'formatNotification'], $notifications);
        usort($formatted, function ($a, $b) {
            return (strtotime($b['created_at'] ?? '1970-01-01') <=> strtotime($a['created_at'] ?? '1970-01-01'));
        });

        $latest = $formatted[0] ?? null;
        return [
            'total' => count($formatted),
            'unread' => self::getUnreadCount($notifications),
            'latest_title' => $latest['title'] ?? '',
            'latest_message' => $latest['message'] ?? '',
        ];
    }
}
