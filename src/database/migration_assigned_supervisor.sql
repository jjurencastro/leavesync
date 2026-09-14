-- Migration: persist the supervisor selected for each leave request.
-- Run once against an existing database after the approval hierarchy migration.

ALTER TABLE leave_requests
    ADD COLUMN assigned_supervisor_id INT NULL AFTER manager_id,
    ADD INDEX idx_assigned_supervisor_id (assigned_supervisor_id),
    ADD FOREIGN KEY (assigned_supervisor_id) REFERENCES users(id) ON DELETE SET NULL;

-- Preserve the current direct supervisor for existing requests where possible.
UPDATE leave_requests lr
JOIN users u ON u.id = lr.user_id
SET lr.assigned_supervisor_id = u.supervisor_id
WHERE lr.assigned_supervisor_id IS NULL
  AND lr.supervisor_status = 'pending';