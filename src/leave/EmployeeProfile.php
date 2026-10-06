<?php

class EmployeeProfile {
    /**
     * Authenticated users can update their non-sensitive profile fields.
     */
    public static function canEditProfile(array $user, string $field): bool {
        $allowed = ['full_name', 'gender', 'department', 'position'];
        return !empty($user['id']) && in_array($field, $allowed, true);
    }

    public static function sanitizeProfileUpdate(array $data): array {
        $allowed = ['full_name', 'gender', 'department', 'position'];
        $clean = [];

        foreach ($allowed as $field) {
            if (array_key_exists($field, $data)) {
                $clean[$field] = trim((string) $data[$field]);
            }
        }

        return $clean;
    }

    /** Creates the details table on first use so existing installs need no manual migration. */
    public static function ensureDetailsTable($db): void {
        $db->execute("CREATE TABLE IF NOT EXISTS employee_profile_details (
            user_id INT PRIMARY KEY,
            nickname VARCHAR(50) NULL,
            contact_number VARCHAR(25) NULL,
            address VARCHAR(255) NULL,
            date_of_birth DATE NULL,
            civil_status VARCHAR(20) NULL,
            emergency_contact_name VARCHAR(100) NULL,
            emergency_contact_relationship VARCHAR(50) NULL,
            emergency_contact_number VARCHAR(25) NULL,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    }

    const DETAIL_FIELDS = [
        'nickname' => 50,
        'contact_number' => 25,
        'address' => 255,
        'date_of_birth' => 10,
        'civil_status' => 20,
        'emergency_contact_name' => 100,
        'emergency_contact_relationship' => 50,
        'emergency_contact_number' => 25,
    ];

    const CIVIL_STATUSES = ['single', 'married', 'widowed', 'separated', 'divorced'];

    /**
     * Validates the optional profile details. Every field may be blank (stored as NULL).
     * Returns [cleanValues, errors]; only fields present in $data are returned.
     */
    public static function sanitizeProfileDetails(array $data): array {
        $clean = [];
        $errors = [];

        foreach (self::DETAIL_FIELDS as $field => $max) {
            if (!array_key_exists($field, $data)) {
                continue;
            }

            $value = trim((string) $data[$field]);
            if ($value === '') {
                $clean[$field] = null;
                continue;
            }

            $label = ucwords(str_replace('_', ' ', $field));
            if (function_exists('mb_strlen') ? mb_strlen($value) > $max : strlen($value) > $max) {
                $errors[] = "$label must be $max characters or fewer";
                continue;
            }

            if (in_array($field, ['contact_number', 'emergency_contact_number'], true)) {
                $digits = preg_replace('/\D/', '', $value);
                if (!preg_match('/^[0-9+\-()\s]+$/', $value) || strlen($digits) < 7 || strlen($digits) > 15) {
                    $errors[] = "$label must be a valid phone number";
                    continue;
                }
            } elseif ($field === 'date_of_birth') {
                $date = DateTime::createFromFormat('!Y-m-d', $value);
                $valid = $date && $date->format('Y-m-d') === $value;
                if (!$valid || $value > date('Y-m-d') || $value < '1900-01-01') {
                    $errors[] = 'Date of birth must be a valid past date';
                    continue;
                }
            } elseif ($field === 'civil_status') {
                $value = strtolower($value);
                if (!in_array($value, self::CIVIL_STATUSES, true)) {
                    $errors[] = 'Civil status is not valid';
                    continue;
                }
            }

            $clean[$field] = $value;
        }

        return [$clean, $errors];
    }
}
