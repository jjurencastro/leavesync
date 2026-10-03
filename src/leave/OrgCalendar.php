<?php
/**
 * Org-wide leave calendar for HR and System Administrator roles.
 *
 * Returns every active employee's pending/approved leave overlapping a date
 * range, optionally restricted to one department. Shape mirrors the employee
 * and manager calendar responses so a single UI can render all three.
 */
require_once __DIR__ . '/CalendarRange.php';

class OrgCalendar {

    /**
     * @param string|null $from       Range start (Y-m-d); defaults to current month
     * @param string|null $to         Range end (Y-m-d); defaults to current month
     * @param string|null $department Optional department filter (exact match)
     * @return array ['success' => true, 'data' => rows, 'from' => ..., 'to' => ...]
     */
    public static function fetch($from, $to, $department = null) {
        [$from, $to] = CalendarRange::normalize($from, $to);

        $db = Database::getInstance();

        $sql = "SELECT lr.id, lr.user_id, u.full_name, u.department, lt.name AS leave_type_name,
                       lr.start_date, lr.end_date, lr.number_of_days, lr.status
                FROM leave_requests lr
                JOIN users u ON lr.user_id = u.id
                JOIN leave_types lt ON lr.leave_type_id = lt.id
                WHERE lr.status IN ('pending', 'approved')
                  AND lr.start_date <= ? AND lr.end_date >= ?";
        $params = [$to, $from];

        $department = trim((string) ($department ?? ''));
        if ($department !== '') {
            $sql .= " AND u.department = ?";
            $params[] = $department;
        }

        $sql .= " ORDER BY lr.start_date, u.full_name";

        return [
            'success' => true,
            'data' => $db->getResults($sql, $params),
            'from' => $from,
            'to' => $to,
        ];
    }
}
