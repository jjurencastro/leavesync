<?php

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../src/database/Database.php';
require_once __DIR__ . '/../src/integration/HrisApi.php';

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');

$response = HrisApi::handle(
    $_SERVER['REQUEST_METHOD'],
    $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '',
    $_GET,
    HRIS_API_KEY_SHA256,
    function () { return Database::getInstance(true); }
);
error_log('HRIS API request: status=' . $response['status']);
http_response_code($response['status']);
if ($response['status'] === 405) {
    header('Allow: GET');
} elseif ($response['status'] === 429) {
    header('Retry-After: 60');
}
echo json_encode($response['body']);
