<?php
/**
 * One-off helper to run a .sql file against the app's configured database
 * using mysqli::multi_query (needed since the deploy image has no `mysql` CLI).
 * Usage: php src/database/run_sql_file.php path/to/file.sql
 */

require_once __DIR__ . '/../../config/config.php';

$path = $argv[1] ?? null;
if (!$path || !is_readable($path)) {
    fwrite(STDERR, "Usage: php run_sql_file.php <path/to/file.sql>\n");
    exit(1);
}

$sql = file_get_contents($path);

$mysqli = new mysqli(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME, DB_PORT);
if ($mysqli->connect_error) {
    fwrite(STDERR, "Connection failed: {$mysqli->connect_error}\n");
    exit(1);
}

if (!$mysqli->multi_query($sql)) {
    fwrite(STDERR, "Query failed: {$mysqli->error}\n");
    exit(1);
}

do {
    if ($result = $mysqli->store_result()) {
        $result->free();
    }
    if ($mysqli->errno) {
        fwrite(STDERR, "Error during execution: {$mysqli->error}\n");
        exit(1);
    }
} while ($mysqli->more_results() && $mysqli->next_result());

echo "SQL file executed successfully.\n";
$mysqli->close();
