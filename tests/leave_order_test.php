<?php
require_once __DIR__ . '/../src/leave/LeaveTypeOrder.php';

$names = [
    'Bereavement Leave',
    'Maternity Leave',
    'Vacation Leave',
    'Paternity Leave',
    'Sick Leave',
];

$ordered = LeaveTypeOrder::sortNames($names);
$expected = [
    'Vacation Leave',
    'Sick Leave',
    'Paternity Leave',
    'Maternity Leave',
    'Bereavement Leave',
];

if ($ordered !== $expected) {
    fwrite(STDERR, "Expected: " . json_encode($expected) . PHP_EOL);
    fwrite(STDERR, "Actual:   " . json_encode($ordered) . PHP_EOL);
    exit(1);
}

echo "PASS: leave type ordering follows the required credit sequence\n";
