<?php
/**
 * New-account registration, self-activation (password + profile setup),
 * and department/position configuration.
 */

require_once __DIR__ . '/../database/Database.php';
require_once __DIR__ . '/../security/DigitalSignature.php';
require_once __DIR__ . '/../mail/Mailer.php';
require_once __DIR__ . '/AuditLogger.php';

class UserRegistration {

    const ALLOWED_DEPARTMENTS = ['ADMIN', 'CCS', 'CTE', 'CBE', 'BED'];

    // Positions available per department, shown in the activation form based on the chosen department
    const DEPARTMENT_POSITIONS = [
        'CCS' => ['Dean', 'Instructor'],
        'CTE' => ['Dean', 'Instructor'],
        'CBE' => ['Dean', 'Instructor'],
        'BED' => ['Principal', 'Assistant Principal', 'Teacher', 'Staff'],
        'ADMIN' => [
            'HR Officer', 'Registrar Officer', 'Finance Officer', 'IT Officer',
            'Librarian', 'Guidance Counselor', 'Nurse', 'Facilities Staff', 'Security Officer', 'Staff'
        ],
    ];

    // Job title/position -> permission tier that governs what the account can access
    // (default suggestion only; the System Administrator can override this after activation)
    const POSITION_ROLE_MAP = [
        'Dean' => 'manager',
        'Principal' => 'manager',
        'Assistant Principal' => 'employee',
        'Teacher' => 'employee',
        'Instructor' => 'employee',
        'HR Officer' => 'hr',
        'Registrar Officer' => 'employee',
        'Finance Officer' => 'employee',
        'IT Officer' => 'employee',
        'Librarian' => 'employee',
        'Guidance Counselor' => 'employee',
        'Nurse' => 'employee',
        'Facilities Staff' => 'employee',
        'Security Officer' => 'employee',
        'Staff' => 'employee',
    ];

    /**
     * Register new user
     * @param array $data User registration data
     * @return array ['success' => bool, 'message' => string, 'user_id' => int]
     */
    public static function register($data) {
        try {
            $errors = self::validate($data);
            if (!empty($errors)) {
                return ['success' => false, 'message' => implode(', ', $errors)];
            }

            $db = Database::getInstance();

            $existing = $db->getRow(
                "SELECT id FROM users WHERE email = ? OR username = ?",
                [$data['email'], $data['username']]
            );

            if ($existing) {
                return ['success' => false, 'message' => 'Email or username already exists'];
            }

            $password_hash = password_hash($data['password'], PASSWORD_BCRYPT);
            $key_pair = DigitalSignature::generateKeyPair();

            $registrationId = self::reserveNextUserId();
            $sql = "INSERT INTO users
                    (id, username, email, password_hash, full_name, department, public_key)
                    VALUES (?, ?, ?, ?, ?, ?, ?)";
            $values = [
                $registrationId, $data['username'], $data['email'], $password_hash, $data['full_name'],
                $data['department'] ?? 'General', $key_pair['public_key']
            ];
            $db->execute($sql, $values);

            $user_id = $db->lastInsertId();
            self::initializeLeaveBalances($user_id);

            return [
                'success' => true,
                'message' => 'User registered successfully',
                'user_id' => $user_id
            ];

        } catch (Exception $e) {
            error_log("Registration error: " . $e->getMessage());
            return ['success' => false, 'message' => 'Registration failed'];
        }
    }

    /**
     * Set the password for the currently authenticated user, activating
     * full username/password login for accounts created via Google sign-in.
     * @param int $user_id
     * @param string $password
     * @return array ['success' => bool, 'message' => string]
     */
    public static function setPassword($user_id, $password, array $data = []) {
        $passwordError = self::passwordValidationError($password);
        if ($passwordError !== null) {
            return ['success' => false, 'message' => $passwordError];
        }

        $db = Database::getInstance();
        $user = $db->getRow(
            "SELECT id, username, full_name, gender, department, position, supervisor_id, password_set FROM users WHERE id = ?",
            [$user_id]
        );
        if (!$user || !empty($user['password_set'])) {
            return ['success' => false, 'message' => 'This account is not awaiting activation'];
        }
        if (empty($user['gender']) || empty($user['department']) || empty($user['position']) || empty($user['supervisor_id'])) {
            return ['success' => false, 'message' => 'An administrator must complete your account profile before activation'];
        }
        if (empty($data['trust_device'])) {
            return ['success' => false, 'message' => 'Please confirm that this device will be registered as trusted'];
        }

        $password_hash = password_hash($password, PASSWORD_BCRYPT);
        $db->execute(
            "UPDATE users SET password_hash = ?, password_set = 1, is_active = 1 WHERE id = ? AND password_set = 0",
            [$password_hash, $user_id]
        );

        AuditLogger::log($user_id, 'password_set', 'user', $user_id);
        $deviceId = DeviceFingerprint::store($user_id, true, $data, true);
        if (!empty($_COOKIE['auth_token'])) {
            $db->execute(
                "UPDATE sessions SET device_id = ? WHERE token_hash = ? AND user_id = ?",
                [$deviceId, hash('sha256', $_COOKIE['auth_token']), $user_id]
            );
        }
        $db->execute(
            "INSERT INTO notifications (user_id, title, message, notification_type, related_entity_type, related_entity_id) VALUES (?, ?, ?, ?, ?, ?)",
            [$user_id, 'Account activated', 'Your password was set and this device was registered as a trusted device.', 'success', 'user', $user_id]
        );

        return ['success' => true, 'message' => 'Password set successfully. This device is now trusted.'];
    }

    /**
     * Change the password for an already-active account, verifying the current
     * password first. Used from the account settings page.
     */
    public static function changePassword($user_id, $currentPassword, $newPassword) {
        $passwordError = self::passwordValidationError($newPassword);
        if ($passwordError !== null) {
            return ['success' => false, 'message' => 'New ' . lcfirst($passwordError)];
        }

        $db = Database::getInstance();
        $user = $db->getRow("SELECT password_hash FROM users WHERE id = ?", [$user_id]);
        if (!$user || !password_verify($currentPassword ?? '', $user['password_hash'])) {
            return ['success' => false, 'message' => 'Current password is incorrect'];
        }

        $password_hash = password_hash($newPassword, PASSWORD_BCRYPT);
        $db->execute("UPDATE users SET password_hash = ? WHERE id = ?", [$password_hash, $user_id]);

        AuditLogger::log($user_id, 'password_changed', 'user', $user_id);

        return ['success' => true, 'message' => 'Password changed successfully'];
    }

    /**
     * Self-service password reset requested from the login page. Emails a
     * temporary password and flags the account as not-activated so the next
     * login is forced through /activate to set a new password. Always returns
     * the same generic message so account existence cannot be probed.
     * @param string $identifier Username or email entered on the login page
     */
    public static function requestPasswordReset($identifier) {
        $generic = ['success' => true, 'message' => 'If an account matches that username, a temporary password has been sent to its registered email address.'];

        $identifier = trim((string)$identifier);
        if ($identifier === '') {
            return $generic;
        }

        $db = Database::getInstance();
        $user = $db->getRow(
            "SELECT id, username, email, full_name, password_set FROM users WHERE username = ? OR email = ?",
            [$identifier, $identifier]
        );

        // TEMP DIAGNOSTIC
        error_log("RESET-DEBUG: identifier='{$identifier}' user_found=" . ($user ? 'yes(id=' . $user['id'] . ',password_set=' . $user['password_set'] . ')' : 'no'));

        if (!$user) {
            return $generic;
        }

        // Accounts that never finished activation have no password to reset.
        // A reset-in-progress account also has password_set = 0 (an earlier
        // request set it), so allow a re-request when a previous reset is on
        // record — otherwise a lost email would lock the account out forever.
        // The 5-minute cooldown below still rate-limits repeat sends.
        if (empty($user['password_set'])) {
            $pendingReset = $db->getRow(
                "SELECT id FROM audit_log WHERE user_id = ? AND action = 'password_reset_requested' LIMIT 1",
                [$user['id']]
            );
            error_log("RESET-DEBUG: password_set=0, pendingReset=" . ($pendingReset ? 'yes' : 'no'));
            if (!$pendingReset) {
                return $generic;
            }
        }

        // Cooldown: ignore repeat requests within 5 minutes (audit_log is the ledger)
        $recent = $db->getRow(
            "SELECT id FROM audit_log WHERE user_id = ? AND action = 'password_reset_requested' AND created_at > (NOW() - INTERVAL 5 MINUTE) LIMIT 1",
            [$user['id']]
        );
        if ($recent) {
            error_log("RESET-DEBUG: blocked by 5-minute cooldown for user {$user['id']}");
            return $generic;
        }

        $tempPassword = self::generateTemporaryPassword();
        $db->execute(
            "UPDATE users SET password_hash = ?, password_set = 0 WHERE id = ?",
            [password_hash($tempPassword, PASSWORD_BCRYPT), $user['id']]
        );

        // Invalidate every existing session so the old password can't keep working anywhere
        $db->execute("DELETE FROM sessions WHERE user_id = ?", [$user['id']]);

        AuditLogger::log($user['id'], 'password_reset_requested', 'user', $user['id']);

        $safeName = htmlspecialchars($user['full_name'], ENT_QUOTES, 'UTF-8');
        $loginUrl = rtrim(APP_URL, '/') . '/login';
        $html = "<p>Hello {$safeName},</p>"
            . "<p>A password reset was requested for your LeaveSync account. Your temporary password is:</p>"
            . "<p style=\"font-size: 1.25em; font-weight: bold; letter-spacing: 1px;\">{$tempPassword}</p>"
            . '<p><a href="' . htmlspecialchars($loginUrl, ENT_QUOTES, 'UTF-8') . '">Log in</a> with it and you will be asked to set a new password right away.</p>'
            . "<p>If you did not request this, contact your administrator immediately.</p>"
            . "<p>&mdash; LeaveSync</p>";
        $text = "Hello {$user['full_name']},\n\nA password reset was requested for your LeaveSync account.\n"
            . "Your temporary password is: {$tempPassword}\n\n"
            . "Log in with it and you will be asked to set a new password right away: {$loginUrl}\n\n"
            . "If you did not request this, contact your administrator immediately.\n";

        // TEMP DIAGNOSTIC
        error_log("RESET-DEBUG: attempting send to {$user['email']}; MAIL_TRANSPORT=" . MAIL_TRANSPORT . "; configured=" . (Mailer::isConfigured() ? 'yes' : 'no'));
        $sent = Mailer::send($user['email'], $user['full_name'], 'LeaveSync: your temporary password', $html, $text);
        error_log("RESET-DEBUG: Mailer::send returned " . var_export($sent, true));

        return $generic;
    }

    /**
     * 12-character temporary password from an unambiguous alphabet
     * (no 0/O, 1/l/I) so it survives being read from an email.
     */
    private static function generateTemporaryPassword() {
        $alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
        $max = strlen($alphabet) - 1;
        $password = '';
        for ($i = 0; $i < 12; $i++) {
            $password .= $alphabet[random_int(0, $max)];
        }
        return $password;
    }

    /**
     * Remove an account whose activation was abandoned before a password was set.
     * Never deletes an established account: any account that has been through a
     * password reset (or ever had a password) is rejected, so a reset-in-progress
     * account cannot be wiped via this endpoint.
     */
    public static function cancelActivation($user_id) {
        $db = Database::getInstance();
        $user = $db->getRow(
            "SELECT is_active, password_set FROM users WHERE id = ?",
            [$user_id]
        );

        if (!$user) {
            return ['success' => false, 'message' => 'User not found'];
        }

        if ((int) $user['is_active'] !== 0 || (int) $user['password_set'] !== 0) {
            return ['success' => false, 'message' => 'This account can no longer be cancelled'];
        }

        // An established account mid-password-reset also has is_active=0/password_set=0,
        // but must never be deletable here. Its reset request is the tell.
        $wasReset = $db->getRow(
            "SELECT id FROM audit_log WHERE user_id = ? AND action IN ('password_reset_requested', 'password_set', 'password_changed') LIMIT 1",
            [$user_id]
        );
        if ($wasReset) {
            return ['success' => false, 'message' => 'This account can no longer be cancelled'];
        }

        $connection = $db->getConnection();
        $connection->begin_transaction();

        try {
            $deleted = $db->execute("DELETE FROM users WHERE id = ? AND is_active = 0 AND password_set = 0", [$user_id]);
            if (!$deleted) {
                $connection->rollback();
                return ['success' => false, 'message' => 'This account can no longer be cancelled'];
            }
            $connection->commit();
            return ['success' => true, 'message' => 'Account activation cancelled'];
        } catch (Exception $e) {
            $connection->rollback();
            error_log('Cancel activation error: ' . $e->getMessage());
            return ['success' => false, 'message' => 'Failed to cancel account activation'];
        }
    }

    /**
     * Alert whoever approves the pending account: the Dean for academic
     * departments, HR for Dean accounts (Deans report to HR), or admin for
     * the ADMIN department (which has no Dean).
     */
    private static function notifyApprovers($user_id, $department) {
        $db = Database::getInstance();
        $applicant = $db->getRow("SELECT full_name, supervisor_id FROM users WHERE id = ?", [$user_id]);
        $approvers = $db->getResults(
            "SELECT id FROM users WHERE id = ? AND is_active = 1 AND role IN ('manager', 'hr', 'admin')",
            [$applicant['supervisor_id'] ?? 0]
        );

        foreach ($approvers as $approver) {
            $db->execute(
                "INSERT INTO notifications (user_id, title, message, notification_type, related_entity_type, related_entity_id) VALUES (?, ?, ?, ?, ?, ?)",
                [$approver['id'], 'New Account Pending Approval', ($applicant['full_name'] ?? 'A new user') . ' has requested account activation.', 'info', 'user', $user_id]
            );
        }
    }

    public static function getActivationInfo($user_id) {
        $db = Database::getInstance();
        $user = $db->getRow(
            "SELECT username, full_name, email FROM users WHERE id = ?",
            [$user_id]
        );

        // A password-reset flow (vs first-time activation) is identified by a
        // prior password_reset_requested audit entry. This lets the activation
        // page show "Reset your password" wording and swap the account-deleting
        // Cancel button for a plain logout for established users.
        $reset = $db->getRow(
            "SELECT id FROM audit_log WHERE user_id = ? AND action = 'password_reset_requested' LIMIT 1",
            [$user_id]
        );

        return [
            'success' => true,
            'data' => [
                'user' => $user,
                'is_reset' => (bool)$reset,
            ]
        ];
    }

    /**
     * Every active supervisor (manager), HR and admin account, regardless of department or position.
     * @param int $excludeUserId Never offer the user as their own supervisor
     */
    public static function getEligibleSupervisors($excludeUserId) {
        $db = Database::getInstance();
        return $db->getResults(
            "SELECT id, username, full_name, department, position, role FROM users
             WHERE id <> ? AND (is_active = 1 OR (is_active = 0 AND password_set = 0)) AND role IN ('admin', 'hr', 'manager')
             ORDER BY full_name, username",
            [$excludeUserId]
        );
    }

    /**
     * Any active supervisor, HR or admin may be chosen, in any department. The department and
     * position arguments are kept for existing callers but no longer restrict the choice.
     * A supervisor who already reports (directly or indirectly) to the user is rejected so
     * reporting lines can never form a loop.
     */
    public static function isEligibleSupervisor($supervisorId, $excludeUserId, $department = null, $position = null, $customDb = null) {
        $db = $customDb ?: Database::getInstance();

        $supervisor = $db->getRow(
            "SELECT id FROM users WHERE id = ? AND id <> ? AND (is_active = 1 OR (is_active = 0 AND password_set = 0)) AND role IN ('admin', 'hr', 'manager')",
            [$supervisorId, $excludeUserId]
        );
        if (!$supervisor) {
            return false;
        }

        return !($excludeUserId && self::reportsTo($db, $supervisorId, $excludeUserId));
    }

    private static function reportsTo($db, $startId, $targetId) {
        $current = (int) $startId;
        $seen = [];
        for ($i = 0; $i < 50 && $current > 0 && !isset($seen[$current]); $i++) {
            if ($current === (int) $targetId) {
                return true;
            }
            $seen[$current] = true;
            $row = $db->getRow("SELECT supervisor_id FROM users WHERE id = ?", [$current]);
            $current = (int) ($row['supervisor_id'] ?? 0);
        }
        return false;
    }

    /**
     * Resolve a supervisor identifier (ID, email, or username) to an eligible supervisor user record.
     * @param string|int $identifier Numeric user ID, email address, or username
     * @param int $excludeUserId
     * @param string $department
     * @param string|null $position
     * @param object|null $customDb Optional custom database mock
     * @return array|null User row if valid and eligible, null otherwise
     */
    public static function resolveEligibleSupervisor($identifier, $excludeUserId, $department, $position = null, $customDb = null) {
        $db = $customDb ?: Database::getInstance();
        $identifier = trim((string)$identifier);
        if ($identifier === '') return null;

        if (is_numeric($identifier)) {
            $user = $db->getRow("SELECT id, username, email, full_name, role, department FROM users WHERE id = ?", [(int)$identifier]);
        } else {
            $user = $db->getRow(
                "SELECT id, username, email, full_name, role, department FROM users WHERE LOWER(email) = LOWER(?) OR LOWER(username) = LOWER(?)",
                [$identifier, $identifier]
            );
        }

        if (!$user) return null;

        $supervisorId = (int)$user['id'];
        if ($supervisorId === (int)$excludeUserId) return null;

        if (self::isEligibleSupervisor($supervisorId, $excludeUserId, $department, $position, $customDb)) {
            return $user;
        }

        return null;
    }

    public static function isValidDepartmentPosition($department, $position) {
        $position = (string) $position;
        $positionLength = preg_match_all('/./us', $position, $matches);
        return in_array($department, self::ALLOWED_DEPARTMENTS, true)
            && $position !== ''
            && $position === trim($position)
            && $positionLength !== false
            && $positionLength <= 50;
    }

    public static function getDefaultRoleForPosition($department, $position) {
        if (!in_array($position, self::DEPARTMENT_POSITIONS[$department] ?? [], true)) {
            return 'employee';
        }
        return self::POSITION_ROLE_MAP[$position] ?? 'employee';
    }

    public static function getDepartmentOptions() {
        return [
            'departments' => self::ALLOWED_DEPARTMENTS,
            'department_positions' => self::DEPARTMENT_POSITIONS,
            'position_role_map' => self::POSITION_ROLE_MAP,
        ];
    }

    public static function reserveNextUserId() {
        $db = Database::getInstance();
        $sequence = $db->getRow("SELECT next_id FROM user_id_sequence WHERE id = 1");
        if (!$sequence) {
            $db->execute("INSERT INTO user_id_sequence (id, next_id) VALUES (1, 2)");
            $sequence = ['next_id' => 2];
        }
        $nextId = (int) $sequence['next_id'];
        $db->execute("UPDATE user_id_sequence SET next_id = ? WHERE id = 1", [$nextId + 1]);
        return $nextId;
    }

    /**
     * Seed a user's leave_balances rows from the current leave_types catalog.
     * Called for every new account, regardless of signup path (register() or Google OAuth).
     */
    public static function initializeLeaveBalances($user_id) {
        try {
            $db = Database::getInstance();
            $leaveTypes = $db->getResults('SELECT id, days_per_year FROM leave_types');

            foreach ($leaveTypes as $leaveType) {
                $existing = $db->getRow(
                    'SELECT id FROM leave_balances WHERE user_id = ? AND leave_type_id = ?',
                    [$user_id, $leaveType['id']]
                );

                if ($existing) {
                    continue;
                }

                $days = (float) $leaveType['days_per_year'];

                $db->execute(
                    'INSERT INTO leave_balances (user_id, leave_type_id, total_days, used_days, pending_days, balance, fiscal_year) VALUES (?, ?, ?, 0, 0, ?, ?)',
                    [$user_id, $leaveType['id'], $days, $days, date('Y')]
                );
            }
        } catch (Exception $e) {
            error_log('Leave balance initialization error: ' . $e->getMessage());
        }
    }

    /**
     * Validate registration data
     * @param array $data Registration data
     * @return array Validation errors
     */
    private static function validate($data) {
        $errors = [];

        if (empty($data['username']) || strlen($data['username']) < 3) {
            $errors[] = 'Username must be at least 3 characters';
        }

        if (empty($data['email']) || !filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            $errors[] = 'Valid email is required';
        } else {
            $domain = strtolower(substr(strrchr($data['email'], '@'), 1));
            if (!empty(ALLOWED_EMAIL_DOMAIN) && $domain !== strtolower(ALLOWED_EMAIL_DOMAIN)) {
                $errors[] = 'Email must be a @' . ALLOWED_EMAIL_DOMAIN . ' address';
            }
        }

        $passwordError = self::passwordValidationError($data['password'] ?? '');
        if ($passwordError !== null) {
            $errors[] = $passwordError;
        }

        if (empty($data['full_name'])) {
            $errors[] = 'Full name is required';
        }

        return $errors;
    }

    private static function passwordValidationError($password) {
        $password = (string) $password;
        if (strlen($password) < 8
            || !preg_match('/[a-z]/', $password)
            || !preg_match('/[A-Z]/', $password)
            || !preg_match('/[0-9]/', $password)
            || !preg_match('/[^A-Za-z0-9\s]/', $password)) {
            return 'Password must be at least 8 characters and include an uppercase letter, a lowercase letter, a number, and a special character';
        }

        return null;
    }
}
