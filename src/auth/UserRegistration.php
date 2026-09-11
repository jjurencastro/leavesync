<?php
/**
 * New-account registration, self-activation (password + profile setup),
 * and department/position configuration.
 */

require_once __DIR__ . '/../database/Database.php';
require_once __DIR__ . '/../security/DigitalSignature.php';
require_once __DIR__ . '/AuditLogger.php';

class UserRegistration {

    const ALLOWED_DEPARTMENTS = ['ADMIN', 'CCS', 'CTE', 'CBE'];

    // Positions available per department, shown in the activation form based on the chosen department
    const DEPARTMENT_POSITIONS = [
        'CCS' => ['Dean', 'Instructor'],
        'CTE' => ['Dean', 'Instructor'],
        'CBE' => ['Dean', 'Instructor'],
        'ADMIN' => [
            'HR Officer', 'Registrar Officer', 'Finance Officer', 'IT Officer',
            'Librarian', 'Guidance Counselor', 'Nurse', 'Facilities Staff', 'Security Officer', 'Staff'
        ],
    ];

    // Job title/position -> permission tier that governs what the account can access
    // (default suggestion only; the System Administrator can override this after activation)
    const POSITION_ROLE_MAP = [
        'Dean' => 'manager',
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
        if (empty($password) || strlen($password) < 8) {
            return ['success' => false, 'message' => 'Password must be at least 8 characters'];
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
        if (empty($newPassword) || strlen($newPassword) < 8) {
            return ['success' => false, 'message' => 'New password must be at least 8 characters'];
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
     * Remove an account whose activation was abandoned before a password was set.
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

        return [
            'success' => true,
            'data' => [
                'user' => $user,
            ]
        ];
    }

    /**
     * @param int $excludeUserId Never offer the user as their own supervisor
     * @param string|null $department Restrict managers to this department; null allows any (used by the activation form, which filters client-side per department/position)
     */
    public static function getEligibleSupervisors($excludeUserId, $department = null) {
        $db = Database::getInstance();
        if ($department !== null) {
            return $db->getResults(
                "SELECT id, username, full_name, department, role FROM users
                 WHERE id <> ? AND is_active = 1 AND (role = 'admin' OR role = 'hr' OR (role = 'manager' AND department = ?))
                 ORDER BY full_name, username",
                [$excludeUserId, $department]
            );
        }
        return $db->getResults(
            "SELECT id, username, full_name, department, role FROM users
             WHERE id <> ? AND is_active = 1 AND role IN ('admin', 'hr', 'manager')
             ORDER BY full_name, username",
            [$excludeUserId]
        );
    }

    // Hierarchy: ADMIN-department staff report to admin, Deans report to HR, other academic positions report to their department's Dean
    public static function isEligibleSupervisor($supervisorId, $excludeUserId, $department, $position = null) {
        $db = Database::getInstance();

        if ($department === 'ADMIN') {
            $supervisor = $db->getRow(
                "SELECT id FROM users WHERE id = ? AND id <> ? AND is_active = 1 AND role = 'admin'",
                [$supervisorId, $excludeUserId]
            );
            return (bool) $supervisor;
        }

        if ($position === 'Dean') {
            $supervisor = $db->getRow(
                "SELECT id FROM users WHERE id = ? AND id <> ? AND is_active = 1 AND role = 'hr'",
                [$supervisorId, $excludeUserId]
            );
            return (bool) $supervisor;
        }

        $supervisor = $db->getRow(
            "SELECT id FROM users WHERE id = ? AND id <> ? AND is_active = 1
             AND role = 'manager' AND department = ?",
            [$supervisorId, $excludeUserId, $department]
        );
        return (bool) $supervisor;
    }

    public static function isValidDepartmentPosition($department, $position) {
        return in_array($department, self::ALLOWED_DEPARTMENTS, true)
            && in_array($position, self::DEPARTMENT_POSITIONS[$department] ?? [], true);
    }

    public static function getDepartmentOptions() {
        return [
            'departments' => self::ALLOWED_DEPARTMENTS,
            'department_positions' => self::DEPARTMENT_POSITIONS,
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

        if (empty($data['password']) || strlen($data['password']) < 8) {
            $errors[] = 'Password must be at least 8 characters';
        }

        if (empty($data['full_name'])) {
            $errors[] = 'Full name is required';
        }

        return $errors;
    }
}
