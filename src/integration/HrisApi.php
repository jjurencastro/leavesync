<?php

class HrisApi {
    private const PAGE_SIZE = 100;
    private const REQUEST_LIMIT = 120;

    private const QUERIES = [
        'employees' => 'SELECT id, email, full_name, department, position, role, is_active, created_at, updated_at FROM users',
        'leave_requests' => 'SELECT id, user_id, leave_type_id, start_date, end_date, number_of_days, status, supervisor_status, hr_status, created_at, updated_at FROM leave_requests',
        'leave_balances' => 'SELECT id, user_id, leave_type_id, total_days, used_days, pending_days, balance, fiscal_year, created_at, updated_at FROM leave_balances',
        'leave_types' => 'SELECT id, name, days_per_year, is_paid, requires_documentation, created_at, updated_at FROM leave_types',
    ];

    public static function handle($method, $authorization, array $params, $keyHash, callable $database) {
        $action = $params['action'] ?? '';
        if (!is_string($action)) {
            $action = '';
        }

        if (!preg_match('/^[a-f0-9]{64}$/', $keyHash)) {
            error_log('HRIS API: integration disabled or key hash invalid');
            return self::response(503, 'HRIS integration is unavailable');
        }
        if (!is_string($authorization)
            || !preg_match('/^Bearer ([a-f0-9]{64})$/i', $authorization, $matches)
            || !hash_equals($keyHash, hash('sha256', $matches[1]))) {
            error_log('HRIS API: authentication failed');
            return self::response(401, 'Unauthorized');
        }
        try {
            $db = $database();
            $db->query("SET time_zone = '+00:00'");
            $db->execute(
                'INSERT INTO hris_api_rate_limit (id, window_start, request_count) VALUES (1, FLOOR(UNIX_TIMESTAMP() / 60) * 60, 1)
                 ON DUPLICATE KEY UPDATE request_count = IF(window_start = VALUES(window_start), request_count + 1, 1),
                 window_start = VALUES(window_start)'
            );
            $rate = $db->getRow('SELECT request_count FROM hris_api_rate_limit WHERE id = 1');
            if (!$rate) {
                throw new RuntimeException('HRIS rate limit record unavailable');
            }
            if ((int) $rate['request_count'] > self::REQUEST_LIMIT) {
                error_log('HRIS API: rate limit exceeded');
                return self::response(429, 'Rate limit exceeded');
            }

            if ($method !== 'GET') {
                return self::response(405, 'Method not allowed');
            }
            if (!isset(self::QUERIES[$action])) {
                return self::response(400, 'Invalid action');
            }
            $cursor = self::parseInteger($params['cursor'] ?? '0', 0, PHP_INT_MAX);
            $limit = self::parseInteger($params['limit'] ?? (string) self::PAGE_SIZE, 1, self::PAGE_SIZE);
            if ($cursor === null || $limit === null) {
                return self::response(400, 'Invalid cursor or limit');
            }

            $rows = $db->getResults(self::QUERIES[$action] . ' WHERE id > ? ORDER BY id ASC LIMIT ?', [$cursor, $limit + 1]);
            $hasMore = count($rows) > $limit;
            if ($hasMore) {
                array_pop($rows);
            }
            $nextCursor = $hasMore ? (string) $rows[count($rows) - 1]['id'] : null;
            error_log("HRIS API: action={$action} status=200 count=" . count($rows));
            return [
                'status' => 200,
                'body' => ['success' => true, 'data' => $rows, 'next_cursor' => $nextCursor],
            ];
        } catch (Throwable $e) {
            error_log('HRIS API error: ' . $e->getMessage());
            return self::response(500, 'Unable to retrieve HRIS data');
        }
    }

    private static function parseInteger($value, $min, $max) {
        if (!is_string($value) || !preg_match('/^(0|[1-9][0-9]*)$/D', $value)) {
            return null;
        }
        $number = filter_var($value, FILTER_VALIDATE_INT, ['options' => ['min_range' => $min, 'max_range' => $max]]);
        return $number === false ? null : $number;
    }

    private static function response($status, $message) {
        return ['status' => $status, 'body' => ['success' => false, 'message' => $message]];
    }
}
