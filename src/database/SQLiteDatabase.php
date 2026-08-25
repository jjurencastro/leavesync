<?php
class SQLiteDatabase {
    private static $instance = null;
    private $db;

    private function __construct() {
        $path = __DIR__ . '/../../storage/leavesync.sqlite';
        $dir = dirname($path);
        if (!is_dir($dir)) {
            mkdir($dir, 0777, true);
        }
        $this->db = new PDO('sqlite:' . $path);
        $this->db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $this->initializeSchema();
    }

    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    private function initializeSchema() {
        $this->ensureTableExists('users', "
            CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE NOT NULL,
                email TEXT UNIQUE NOT NULL,
                password_hash TEXT NOT NULL,
                full_name TEXT NOT NULL,
                department TEXT,
                role TEXT DEFAULT 'employee',
                is_active INTEGER DEFAULT 1,
                device_fingerprint TEXT,
                public_key TEXT,
                password_set INTEGER DEFAULT 1,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ");
        $this->ensureColumnExists('users', 'device_fingerprint', 'TEXT');
        $this->ensureColumnExists('users', 'password_set', 'INTEGER DEFAULT 1');

        $this->ensureTableExists('sessions', "
            CREATE TABLE sessions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                token_hash TEXT UNIQUE NOT NULL,
                device_id INTEGER,
                ip_address TEXT,
                expires_at TEXT NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ");

        $this->ensureTableExists('device_fingerprints', "
            CREATE TABLE device_fingerprints (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                fingerprint_hash TEXT NOT NULL,
                device_info TEXT,
                ip_address TEXT,
                browser_info TEXT,
                is_trusted INTEGER DEFAULT 0,
                last_used DATETIME DEFAULT CURRENT_TIMESTAMP,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ");

        $this->ensureTableExists('audit_log', "
            CREATE TABLE audit_log (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER,
                action TEXT NOT NULL,
                entity_type TEXT,
                entity_id INTEGER,
                old_values TEXT,
                new_values TEXT,
                ip_address TEXT,
                device_fingerprint TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ");

        $this->ensureTableExists('mfa_secrets', "
            CREATE TABLE mfa_secrets (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL UNIQUE,
                secret TEXT NOT NULL,
                backup_codes TEXT,
                is_enabled INTEGER DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ");

        $this->ensureTableExists('leave_types', "
            CREATE TABLE leave_types (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
                days_per_year INTEGER NOT NULL,
                is_paid INTEGER DEFAULT 1,
                requires_documentation INTEGER DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ");

        $this->ensureTableExists('leave_requests', "
            CREATE TABLE leave_requests (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                leave_type_id INTEGER NOT NULL,
                start_date TEXT NOT NULL,
                end_date TEXT NOT NULL,
                number_of_days REAL,
                reason TEXT,
                status TEXT DEFAULT 'pending',
                manager_id INTEGER,
                manager_comments TEXT,
                digital_signature TEXT,
                signature_timestamp DATETIME,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ");

        $this->ensureTableExists('digital_signatures', "
            CREATE TABLE digital_signatures (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                document_id INTEGER NOT NULL,
                document_type TEXT NOT NULL,
                signer_id INTEGER NOT NULL,
                signature_hash TEXT NOT NULL,
                certificate_data TEXT,
                timestamp DATETIME NOT NULL,
                is_valid INTEGER DEFAULT 1,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ");

        $this->ensureTableExists('leave_balances', "
            CREATE TABLE leave_balances (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL UNIQUE,
                leave_type_id INTEGER NOT NULL,
                total_days REAL,
                used_days REAL DEFAULT 0,
                pending_days REAL DEFAULT 0,
                balance REAL,
                fiscal_year INTEGER,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ");

        $this->ensureTableExists('notifications', "
            CREATE TABLE notifications (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                message TEXT,
                notification_type TEXT,
                related_entity_type TEXT,
                related_entity_id INTEGER,
                is_read INTEGER DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                read_at DATETIME
            )
        ");

        $this->ensureTableExists('device_change_requests', "
            CREATE TABLE device_change_requests (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                fingerprint_hash TEXT NOT NULL,
                device_info TEXT,
                ip_address TEXT,
                browser_info TEXT,
                status TEXT DEFAULT 'pending',
                requested_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                resolved_at DATETIME,
                resolved_by INTEGER
            )
        ");

        $this->seedLeaveTypes();
    }

    private function seedLeaveTypes() {
        $count = (int) $this->db->query("SELECT COUNT(*) FROM leave_types")->fetchColumn();
        if ($count > 0) {
            return;
        }

        $this->db->exec("INSERT INTO leave_types (name, description, days_per_year, is_paid, requires_documentation) VALUES
            ('Sick Leave', 'Leave for medical reasons', 10, 1, 0),
            ('Annual Leave', 'Paid vacation leave', 20, 1, 0),
            ('Unpaid Leave', 'Leave without pay', 30, 0, 1),
            ('Maternity Leave', 'Leave for maternity', 90, 1, 1),
            ('Paternity Leave', 'Leave for paternity', 10, 1, 0),
            ('Casual Leave', 'Casual absence', 5, 1, 0)");
    }

    private function ensureTableExists($table, $sql) {
        $stmt = $this->db->query("SELECT name FROM sqlite_master WHERE type='table' AND name = '{$table}'");
        if ($stmt->fetchColumn() === false) {
            $this->db->exec($sql);
        }
    }

    private function ensureColumnExists($table, $column, $definition) {
        $stmt = $this->db->query("PRAGMA table_info({$table})");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($columns as $col) {
            if ($col['name'] === $column) {
                return;
            }
        }

        $this->db->exec("ALTER TABLE {$table} ADD COLUMN {$column} {$definition}");
    }

    public function getConnection() {
        return $this->db;
    }

    public function query($sql, $params = []) {
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        return $stmt;
    }

    public function getResults($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getRow($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function execute($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->rowCount() > 0;
    }

    public function lastInsertId() {
        return (int) $this->db->lastInsertId();
    }
}
