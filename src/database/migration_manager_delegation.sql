-- Migration: allow managers to nominate a backup approver.
-- Run once against an existing database.

ALTER TABLE users
    ADD COLUMN backup_approver_id INT NULL AFTER supervisor_id,
    ADD INDEX idx_backup_approver_id (backup_approver_id),
    ADD FOREIGN KEY (backup_approver_id) REFERENCES users(id) ON DELETE SET NULL;