<?php
require_once __DIR__ . '/../src/leave/CalendarRange.php';

function assertTrue($condition, $message) {
    if (!$condition) {
        throw new Exception($message);
    }
}

function assertThrows(callable $fn, $message) {
    try {
        $fn();
    } catch (InvalidArgumentException $e) {
        return;
    }
    throw new Exception($message);
}

// Valid range passes through unchanged
[$from, $to] = CalendarRange::normalize('2026-03-01', '2026-03-31');
assertTrue($from === '2026-03-01' && $to === '2026-03-31', 'A valid range should pass through unchanged');

// Inverted range is swapped
[$from, $to] = CalendarRange::normalize('2026-03-31', '2026-03-01');
assertTrue($from === '2026-03-01' && $to === '2026-03-31', 'An inverted range should be swapped');

// Empty input defaults to the current month
[$from, $to] = CalendarRange::normalize(null, null);
assertTrue($from === date('Y-m-01') && $to === date('Y-m-t'), 'Empty input should default to the current month');

// Malformed dates are rejected
assertThrows(fn() => CalendarRange::normalize('not-a-date', '2026-03-31'), 'A malformed from date should be rejected');
assertThrows(fn() => CalendarRange::normalize('2026-03-01', '31/03/2026'), 'A malformed to date should be rejected');

// Impossible dates are rejected instead of silently rolled over
assertThrows(fn() => CalendarRange::normalize('2026-02-31', '2026-03-31'), 'An impossible date should be rejected');

// Over-long spans are rejected
assertThrows(fn() => CalendarRange::normalize('2026-01-01', '2027-06-01'), 'A span beyond the cap should be rejected');

// Exactly one year is allowed
[$from, $to] = CalendarRange::normalize('2026-01-01', '2026-12-31');
assertTrue($from === '2026-01-01' && $to === '2026-12-31', 'A one-year span should be allowed');

echo "PASS: calendar range validation normalizes, swaps, and rejects bad input\n";
