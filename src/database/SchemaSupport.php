<?php

class SchemaSupport {
    private static $columns = [];

    public static function hasColumn($db, string $table, string $column): bool {
        $key = $table . '.' . $column;
        if (array_key_exists($key, self::$columns)) {
            return self::$columns[$key];
        }

        try {
            $safeTable = preg_replace('/[^a-zA-Z0-9_]/', '', $table);
            $safeColumn = preg_replace('/[^a-zA-Z0-9_]/', '', $column);
            $row = $db->getRow("SHOW COLUMNS FROM `$safeTable` LIKE '$safeColumn'");
            self::$columns[$key] = $row !== null;
        } catch (Throwable $e) {
            self::$columns[$key] = false;
        }

        return self::$columns[$key];
    }
}
