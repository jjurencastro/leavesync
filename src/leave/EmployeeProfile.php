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
}
