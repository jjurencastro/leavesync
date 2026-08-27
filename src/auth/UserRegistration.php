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
    const POSITION_ROLE_MAP = [
        'Dean' => 'manager',
        'Instructor' => 'employee',
        'HR Officer' => 'admin',
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
        $gender = $data['gender'] ?? '';
        $department = trim($data['department'] ?? '');
        $position = trim($data['position'] ?? '');
        $supervisor_id = (int) ($data['supervisor_id'] ?? 0);

        $allowedGenders = ['male', 'female'];
        if (!in_array($gender, $allowedGenders, true)) {
            return ['success' => false, 'message' => 'Please select a valid gender option'];
        }
        if (!in_array($department, self::ALLOWED_DEPARTMENTS, true)) {
            return ['success' => false, 'message' => 'Please select a valid department'];
        }
        if (!in_array($position, self::DEPARTMENT_POSITIONS[$department] ?? [], true)) {
            return ['success' => false, 'message' => 'Please select a valid position for the chosen department'];
        }
        // Account stays pending (is_active = 0) until an admin approves it, so a
        // self-selected manager/admin-tier position has no effect until then.
        $role = self::POSITION_ROLE_MAP[$position];

        $supervisor = $db->getRow(
            "SELECT id FROM users WHERE id = ? AND id <> ? AND is_active = 1
             AND (role = 'admin' OR (role = 'manager' AND department = ?))",
            [$supervisor_id, $user_id, $department]
        );
        if (!$supervisor) {
            return ['success' => false, 'message' => 'Please select an active immediate supervisor'];
        }

        $password_hash = password_hash($password, PASSWORD_BCRYPT);
        $db->execute(
            "UPDATE users SET password_hash = ?, password_set = 1, gender = ?, department = ?, position = ?, role = ?, supervisor_id = ? WHERE id = ?",
            [$password_hash, $gender, $department, $position, $role, $supervisor_id, $user_id]
        );

        AuditLogger::log($user_id, 'password_set', 'user', $user_id);
        self::notifyApprovers($user_id, $department);

        return ['success' => true, 'message' => 'Password set successfully'];
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
     * Alert whoever approves pending accounts for this department: the Dean for
     * academic departments, or admin for the ADMIN department (which has no Dean).
     */
    private static function notifyApprovers($user_id, $department) {
        $db = Database::getInstance();
        $applicant = $db->getRow("SELECT full_name FROM users WHERE id = ?", [$user_id]);
        $approvers = $department === 'ADMIN'
            ? $db->getResults("SELECT id FROM users WHERE role = 'admin' AND is_active = 1")
            : $db->getResults("SELECT id FROM users WHERE role = 'manager' AND department = ? AND is_active = 1", [$department]);

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
        $supervisors = $db->getResults(
            "SELECT id, username, full_name, department, role FROM users
             WHERE id <> ? AND is_active = 1 AND (role = 'admin' OR role = 'manager')
             ORDER BY full_name, username",
            [$user_id]
        );

        return [
            'success' => true,
            'data' => [
                'user' => $user,
                'supervisors' => $supervisors,
                'departments' => self::ALLOWED_DEPARTMENTS,
                'department_positions' => self::DEPARTMENT_POSITIONS,
            ]
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
