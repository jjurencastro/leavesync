<?php
/**
 * Shared validation for calendar date-range query parameters.
 *
 * Calendar endpoints accept ?from=YYYY-MM-DD&to=YYYY-MM-DD. This normalizes
 * that input: strict format validation, swaps an inverted range, and caps the
 * span so a request cannot pull an unbounded slice of the leave_requests table.
 */
class CalendarRange {

    /** Maximum span a single calendar query may cover, inclusive. */
    const MAX_DAYS = 366;

    /**
     * Validate and normalize a date range.
     *
     * @param string|null $from Start date (Y-m-d); null/empty defaults to the first of the current month
     * @param string|null $to   End date (Y-m-d); null/empty defaults to the last of the current month
     * @return array [string $from, string $to] normalized Y-m-d dates, $from <= $to
     * @throws InvalidArgumentException on malformed dates or an over-long span
     */
    public static function normalize($from, $to) {
        $from = trim((string) ($from ?? ''));
        $to = trim((string) ($to ?? ''));

        if ($from === '') {
            $from = date('Y-m-01');
        }
        if ($to === '') {
            $to = date('Y-m-t');
        }

        $fromDate = self::parse($from);
        $toDate = self::parse($to);

        if ($fromDate > $toDate) {
            // Inverted range: swap rather than error so loose clients still work.
            [$fromDate, $toDate] = [$toDate, $fromDate];
        }

        $days = (int) $fromDate->diff($toDate)->days + 1;
        if ($days > self::MAX_DAYS) {
            throw new InvalidArgumentException('Date range cannot exceed ' . self::MAX_DAYS . ' days');
        }

        return [$fromDate->format('Y-m-d'), $toDate->format('Y-m-d')];
    }

    /**
     * Strictly parse a Y-m-d date, rejecting things DateTime would silently
     * roll over (e.g. 2026-02-31) and any trailing characters.
     */
    private static function parse($value) {
        $date = DateTime::createFromFormat('!Y-m-d', $value);
        $errors = DateTime::getLastErrors();
        if ($date === false || ($errors !== false && ($errors['warning_count'] > 0 || $errors['error_count'] > 0))) {
            throw new InvalidArgumentException('Invalid date: ' . $value . ' (expected YYYY-MM-DD)');
        }
        return $date;
    }
}
