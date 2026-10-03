<?php
/**
 * Yearly leave-balance reset (lapse model).
 *
 * Each leave year, every user's balance for each leave type resets to that
 * year's allowance. Unused days are lost (no carry-over). The allowance is
 * resolved per user from leave_policies (matching department/gender, most
 * specific first) for the relevant fiscal year, falling back to
 * leave_types.days_per_year when no policy matches.
 *
 * The leave year's start month is configurable via the app_settings key
 * `leave_year_start_month` (1-12, default 1 = January/calendar year). For a
 * start month > 1 the "leave year" is named after the calendar year in which
 * it begins (e.g. start month 6 => the June 2025–May 2026 cycle is FY2025).
 *
 * Two triggers:
 *   - Lazy: LeaveAccrual::ensureCurrent() runs on balance reads and resets a
 *     user whose leave_balances rows still carry an older fiscal_year.
 *   - Admin: LeaveAccrual::resetAll() forces the reset for every user, called
 *     from an admin "Run yearly reset" button.
 */
require_once __DIR__ . '/../auth/AuditLogger.php';

class LeaveAccrual {

    /**
     * The leave-year label (fiscal_year) for "now", honoring the configured
     * start month. Start month 1 => current calendar year.
     */
    public static function currentLeaveYear() {
        return self::leaveYearForDate(time());
    }

    /** Leave-year label for an arbitrary timestamp. */
    public static function leaveYearForDate($timestamp) {
        $startMonth = self::yearStartMonth();
        $year = (int) date('Y', $timestamp);
        $month = (int) date('n', $timestamp);
        // Before the start month, we are still in the leave year that began
        // in the previous calendar year.
        return ($month >= $startMonth) ? $year : $year - 1;
    }

    /** Configured leave-year start month (1-12). Defaults to 1 (January). */
    public static function yearStartMonth() {
        static $cached = null;
        if ($cached !== null) {
            return $cached;
        }
        $month = 1;
        try {
            $db = Database::getInstance();
            $row = $db->getRow(
                "SELECT setting_value FROM app_settings WHERE setting_key = 'leave_year_start_month'"
            );
            if ($row) {
                $candidate = (int) $row['setting_value'];
                if ($candidate >= 1 && $candidate <= 12) {
                    $month = $candidate;
                }
            }
        } catch (Exception $e) {
            error_log('LeaveAccrual: failed to read leave_year_start_month — ' . $e->getMessage());
        }
        $cached = $month;
        return $cached;
    }

    /**
     * Lazy reset: if any of the user's leave_balances rows belong to an older
     * leave year, reset the whole set to the current year's allowance.
     * Safe to call on every balance read; a no-op when already current.
     */
    public static function ensureCurrent($user_id) {
        $db = Database::getInstance();
        $currentYear = self::currentLeaveYear();

        $stale = $db->getRow(
            "SELECT id FROM leave_balances WHERE user_id = ? AND (fiscal_year IS NULL OR fiscal_year < ?) LIMIT 1",
            [$user_id, $currentYear]
        );

        if ($stale) {
            self::resetUser($user_id, $currentYear, 'lazy');
        } else {
            // Ensure newly added leave types get a row for the current year.
            self::seedMissing($user_id, $currentYear);
        }
    }

    /**
     * Force the yearly reset for every user. Returns the number of users reset.
     */
    public static function resetAll() {
        $db = Database::getInstance();
        $currentYear = self::currentLeaveYear();
        $users = $db->getResults("SELECT id FROM users");
        $count = 0;
        foreach ($users as $u) {
            self::resetUser((int) $u['id'], $currentYear, 'admin');
            $count++;
        }
        return $count;
    }

    /**
     * Reset one user's balances to the leave year's allowance (lapse: unused
     * days are discarded, pending/used zeroed). Seeds rows for any leave type
     * the user does not yet have.
     */
    private static function resetUser($user_id, $leaveYear, $trigger) {
        $db = Database::getInstance();

        // Seed any missing leave types first so every type is covered.
        self::seedMissing($user_id, $leaveYear);

        $balances = $db->getResults(
            "SELECT id, leave_type_id FROM leave_balances WHERE user_id = ?",
            [$user_id]
        );

        foreach ($balances as $balance) {
            $allowance = self::resolveAllowance($user_id, (int) $balance['leave_type_id'], $leaveYear);
            $db->execute(
                "UPDATE leave_balances
                 SET total_days = ?, used_days = 0, pending_days = 0, balance = ?, fiscal_year = ?
                 WHERE id = ?",
                [$allowance, $allowance, $leaveYear, $balance['id']]
            );
        }

        AuditLogger::log($user_id, 'leave_balance_reset', 'user', $user_id, [
            'leave_year' => $leaveYear,
            'trigger' => $trigger,
        ]);
    }

    /**
     * Insert leave_balances rows (at the current year's allowance) for any
     * leave type the user does not yet have a row for.
     */
    private static function seedMissing($user_id, $leaveYear) {
        $db = Database::getInstance();
        $leaveTypes = $db->getResults("SELECT id, days_per_year FROM leave_types");
        foreach ($leaveTypes as $leaveType) {
            $existing = $db->getRow(
                "SELECT id FROM leave_balances WHERE user_id = ? AND leave_type_id = ?",
                [$user_id, $leaveType['id']]
            );
            if ($existing) {
                continue;
            }
            $allowance = self::resolveAllowance($user_id, (int) $leaveType['id'], $leaveYear);
            $db->execute(
                "INSERT INTO leave_balances (user_id, leave_type_id, total_days, used_days, pending_days, balance, fiscal_year)
                 VALUES (?, ?, ?, 0, 0, ?, ?)",
                [$user_id, $leaveType['id'], $allowance, $allowance, $leaveYear]
            );
        }
    }

    /**
     * Resolve the annual allowance for a user + leave type + leave year.
     * Prefers an active leave_policies row for that fiscal year matching the
     * user's department and/or gender (most specific match wins); falls back
     * to leave_types.days_per_year.
     */
    private static function resolveAllowance($user_id, $leave_type_id, $leaveYear) {
        $db = Database::getInstance();

        $user = $db->getRow("SELECT department, gender FROM users WHERE id = ?", [$user_id]);
        $department = $user['department'] ?? null;
        $gender = $user['gender'] ?? null;

        // Candidate policies for this leave type + year, active only.
        $policies = $db->getResults(
            "SELECT days_per_year, department, gender
             FROM leave_policies
             WHERE leave_type_id = ? AND fiscal_year = ? AND is_active = 1",
            [$leave_type_id, $leaveYear]
        );

        $best = null;
        $bestScore = -1;
        foreach ($policies as $policy) {
            // Department must match if the policy restricts it.
            if (!empty($policy['department']) && $policy['department'] !== $department) {
                continue;
            }
            // Gender must match if the policy restricts it.
            if (!empty($policy['gender']) && $policy['gender'] !== $gender) {
                continue;
            }
            // Score by specificity: department match +1, gender match +1.
            $score = 0;
            if (!empty($policy['department'])) $score++;
            if (!empty($policy['gender'])) $score++;
            if ($score > $bestScore) {
                $bestScore = $score;
                $best = (float) $policy['days_per_year'];
            }
        }

        if ($best !== null) {
            return $best;
        }

        $leaveType = $db->getRow("SELECT days_per_year FROM leave_types WHERE id = ?", [$leave_type_id]);
        return $leaveType ? (float) $leaveType['days_per_year'] : 0.0;
    }
}
