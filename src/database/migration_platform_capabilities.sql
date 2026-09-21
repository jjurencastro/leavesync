-- Platform capabilities migration: soft deletion, policy/settings, permissions, and approval escalation.
-- Run once against an existing database.

ALTER TABLE users
    ADD COLUMN deleted_at TIMESTAMP NULL,
    ADD INDEX idx_users_deleted_at (deleted_at);

CREATE TABLE IF NOT EXISTS app_settings (
    setting_key VARCHAR(100) PRIMARY KEY,
    setting_value TEXT NOT NULL,
    updated_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS role_permissions (
    role VARCHAR(30) NOT NULL,
    permission VARCHAR(100) NOT NULL,
    granted BOOLEAN DEFAULT TRUE,
    updated_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (role, permission),
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS leave_policies (
    id INT PRIMARY KEY AUTO_INCREMENT,
    leave_type_id INT NOT NULL,
    department VARCHAR(50) NULL,
    gender VARCHAR(30) NULL,
    fiscal_year INT NOT NULL,
    days_per_year DECIMAL(6,2) NOT NULL,
    approval_threshold_days DECIMAL(6,2) NULL,
    auto_route_role VARCHAR(30) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT NULL,
    updated_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_leave_policy_lookup (leave_type_id, department, fiscal_year, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS approval_escalations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    leave_request_id INT NOT NULL,
    from_user_id INT NULL,
    to_user_id INT NOT NULL,
    reason VARCHAR(255) NOT NULL,
    status ENUM('open', 'resolved', 'cancelled') DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    FOREIGN KEY (leave_request_id) REFERENCES leave_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (from_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (to_user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_escalation_status (status),
    INDEX idx_escalation_request (leave_request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO role_permissions (role, permission) VALUES
    ('employee', 'leave.create'), ('employee', 'leave.view_own'), ('employee', 'leave.cancel_own'),
    ('manager', 'leave.approve_team'), ('manager', 'leave.view_team'), ('manager', 'leave.escalate'), ('manager', 'reports.team'),
    ('hr', 'leave.approve_hr'), ('hr', 'users.manage_records'), ('hr', 'reports.hr'), ('hr', 'policy.view'),
    ('admin', 'users.manage'), ('admin', 'users.restore'), ('admin', 'policy.manage'), ('admin', 'settings.manage'), ('admin', 'audit.view'), ('admin', 'reports.admin');
