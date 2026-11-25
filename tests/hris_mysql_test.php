<?php
if (getenv('HRIS_TEST_MYSQL') !== '1' || getenv('DB_NAME') !== 'hris_test') {
    echo "SKIP: HRIS MySQL test requires an isolated hris_test database\n";
    exit;
}

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../src/database/Database.php';
require_once __DIR__ . '/../src/integration/HrisApi.php';

function assertMysqlHris($condition, $message) {
    if (!$condition) {
        throw new RuntimeException($message);
    }
}

$db = Database::getInstance();
$db->query('CREATE TEMPORARY TABLE hris_api_rate_limit (id TINYINT PRIMARY KEY, window_start BIGINT NOT NULL, request_count INT UNSIGNED NOT NULL)');
$db->query('CREATE TEMPORARY TABLE users (id INT PRIMARY KEY, email VARCHAR(100), full_name VARCHAR(100), department VARCHAR(50), position VARCHAR(50), role VARCHAR(20), is_active BOOLEAN, created_at TIMESTAMP NULL, updated_at TIMESTAMP NULL, password_hash VARCHAR(255))');
$db->query('CREATE TEMPORARY TABLE leave_requests (id INT PRIMARY KEY, user_id INT, leave_type_id INT, start_date DATE, end_date DATE, number_of_days DECIMAL(6,2), status VARCHAR(20), supervisor_status VARCHAR(20), hr_status VARCHAR(20), created_at TIMESTAMP NULL, updated_at TIMESTAMP NULL, reason TEXT)');
$db->query('CREATE TEMPORARY TABLE leave_balances (id INT PRIMARY KEY, user_id INT, leave_type_id INT, total_days DECIMAL(6,2), used_days DECIMAL(6,2), pending_days DECIMAL(6,2), balance DECIMAL(6,2), fiscal_year INT, created_at TIMESTAMP NULL, updated_at TIMESTAMP NULL)');
$db->query('CREATE TEMPORARY TABLE leave_types (id INT PRIMARY KEY, name VARCHAR(50), days_per_year INT, is_paid BOOLEAN, requires_documentation BOOLEAN, created_at TIMESTAMP NULL, updated_at TIMESTAMP NULL)');
$db->execute("INSERT INTO users (id, email, full_name, role, is_active, password_hash) VALUES (1, 'one@example.org', 'One', 'employee', 1, 'private'), (3, 'two@example.org', 'Two', 'admin', 0, 'private')");
$db->execute("INSERT INTO leave_types (id, name, days_per_year, is_paid, requires_documentation) VALUES (1, 'Vacation', 10, 1, 0)");
$db->execute("INSERT INTO leave_requests (id, user_id, leave_type_id, start_date, end_date, number_of_days, status, supervisor_status, hr_status, reason) VALUES (1, 1, 1, '2026-01-01', '2026-01-02', 2, 'pending', 'pending', 'pending', 'private')");
$db->execute("INSERT INTO leave_balances (id, user_id, leave_type_id, total_days, balance, fiscal_year) VALUES (1, 1, 1, 10, 8, 2026)");

$token = str_repeat('a', 64);
$call = function ($params) use ($db, $token) {
    return HrisApi::handle('GET', 'Bearer ' . $token, $params, hash('sha256', $token), function () use ($db) { return $db; });
};
$first = $call(['action' => 'employees', 'limit' => '1']);
assertMysqlHris($first['status'] === 200 && $first['body']['next_cursor'] === '1', 'MySQL pagination first page failed');
assertMysqlHris(!array_key_exists('password_hash', $first['body']['data'][0]), 'Password hash exposed');
$last = $call(['action' => 'employees', 'limit' => '1', 'cursor' => '1']);
assertMysqlHris((int) $last['body']['data'][0]['id'] === 3 && $last['body']['next_cursor'] === null, 'MySQL pagination last page failed');
foreach (['leave_requests', 'leave_balances', 'leave_types'] as $action) {
    $result = $call(['action' => $action]);
    assertMysqlHris($result['status'] === 200 && count($result['body']['data']) === 1, 'MySQL query failed: ' . $action);
    assertMysqlHris(!array_key_exists('reason', $result['body']['data'][0]), 'Leave reason exposed');
}
$db->query('UPDATE hris_api_rate_limit SET request_count = 120');
assertMysqlHris($call(['action' => 'employees'])['status'] === 429, 'MySQL rate limit failed');
$db->query('UPDATE hris_api_rate_limit SET window_start = 0');
assertMysqlHris($call(['action' => 'employees'])['status'] === 200, 'MySQL rate limit window did not reset');

echo "PASS: HRIS MySQL queries, pagination, and rate limit\n";
