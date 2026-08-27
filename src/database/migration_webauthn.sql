-- Migration: WebAuthn passkey approvals (manager/hr/admin only)
-- Run once against an existing database that predates this feature.

CREATE TABLE IF NOT EXISTS webauthn_credentials (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    credential_id VARCHAR(255) NOT NULL UNIQUE,
    public_key TEXT NOT NULL,
    attestation_type VARCHAR(50) NOT NULL DEFAULT 'none',
    trust_path TEXT,
    aaguid VARCHAR(64),
    transports JSON,
    sign_count BIGINT UNSIGNED NOT NULL DEFAULT 0,
    label VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS webauthn_challenges (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    challenge VARCHAR(255) NOT NULL,
    purpose ENUM('registration', 'approval') NOT NULL,
    context_type ENUM('leave_request', 'device_change') NULL,
    context_id INT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_expires_at (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
