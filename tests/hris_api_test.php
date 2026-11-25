<?php
require_once __DIR__ . '/../src/integration/HrisApi.php';

function assertHris($condition, $message) {
    if (!$condition) {
        throw new RuntimeException($message);
    }
}

class HrisTestDatabase {
    public $count = 0;
    public $queries = [];
    public $fail = false;
    public $rows = [];

    public function query($sql) {
        if ($this->fail) {
            throw new RuntimeException('test database failure');
        }
    }

    public function execute($sql, $params = []) {
        $this->count++;
    }

    public function getRow($sql, $params = []) {
        return ['request_count' => $this->count];
    }

    public function getResults($sql, $params = []) {
        $this->queries[] = $sql;
        $rows = array_values(array_filter($this->rows, function ($row) use ($params) {
            return $row['id'] > $params[0];
        }));
        return array_slice($rows, 0, $params[1]);
    }
}

$token = str_repeat('a', 64);
$hash = hash('sha256', $token);
$db = new HrisTestDatabase();
$factoryCalls = 0;
$factory = function () use ($db, &$factoryCalls) {
    $factoryCalls++;
    return $db;
};
$call = function ($params = [], $method = 'GET', $authorization = null, $keyHash = null) use ($token, $hash, $factory) {
    return HrisApi::handle($method, $authorization ?? 'Bearer ' . $token, $params, $keyHash ?? $hash, $factory);
};

assertHris($call(['action' => 'employees'], 'GET', 'Bearer ' . str_repeat('b', 64))['status'] === 401, 'Wrong token must fail');
assertHris($call(['action' => 'employees'], 'GET', 'Bearer ' . $token, '')['status'] === 503, 'Missing key must disable integration');
assertHris($factoryCalls === 0, 'Unauthorized or disabled requests must not access the database');
assertHris($call(['action' => 'employees'], 'POST')['status'] === 405, 'Writes must be rejected');
assertHris($call(['action' => 'users'])['status'] === 400, 'Unknown actions must be rejected');
foreach (['-1', '1.0', '01', '999999999999999999999999999', ['1']] as $badCursor) {
    assertHris($call(['action' => 'employees', 'cursor' => $badCursor])['status'] === 400, 'Invalid cursor must be rejected');
}
foreach (['0', '101', '1 OR 1=1', ['1']] as $badLimit) {
    assertHris($call(['action' => 'employees', 'limit' => $badLimit])['status'] === 400, 'Invalid limit must be rejected');
}

$db->rows = [['id' => 1], ['id' => 3], ['id' => 5]];
$first = $call(['action' => 'employees', 'limit' => '2']);
assertHris($first['status'] === 200 && count($first['body']['data']) === 2, 'First page must be limited');
assertHris($first['body']['next_cursor'] === '3', 'Cursor must be last returned ID');
$last = $call(['action' => 'employees', 'limit' => '2', 'cursor' => $first['body']['next_cursor']]);
assertHris($last['body']['data'][0]['id'] === 5 && $last['body']['next_cursor'] === null, 'Final page must end the scan');

foreach (['employees', 'leave_requests', 'leave_balances', 'leave_types'] as $action) {
    assertHris($call(['action' => $action])['status'] === 200, 'Each agreed action must work');
}
foreach ($db->queries as $sql) {
    assertHris(strpos($sql, 'SELECT *') === false, 'Queries must explicitly select fields');
    assertHris(!preg_match('/password|secret|reason|comments|attachment/i', $sql), 'Sensitive fields must not be selected');
}

$db->count = 120;
assertHris($call(['action' => 'employees'])['status'] === 429, 'Requests over the shared limit must be rejected');
$db->count = 0;
$db->fail = true;
assertHris($call(['action' => 'employees'])['status'] === 500, 'Database errors must not return success');

echo "PASS: HRIS authentication, pagination, rate limiting, and error handling\n";
