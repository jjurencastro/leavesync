-- Supporting-document attachments for leave requests.
-- Apply to existing databases:  mysql leavesync < src/database/migration_leave_attachments.sql
CREATE TABLE IF NOT EXISTS leave_attachments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    leave_request_id INT NOT NULL,
    user_id INT NOT NULL COMMENT 'uploader (the request owner)',
    original_name VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_size INT UNSIGNED NOT NULL,
    file_data LONGBLOB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (leave_request_id) REFERENCES leave_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_leave_request_id (leave_request_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
