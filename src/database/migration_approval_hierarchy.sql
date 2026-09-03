-- Migration: tiered approval hierarchy (HR role + two-stage leave approval)
-- Run once against an existing database that predates this feature.

ALTER TABLE users
    MODIFY role ENUM('employee', 'manager', 'hr', 'admin') DEFAULT 'employee';

-- Deans use the department-manager dashboard and approval permissions.
UPDATE users SET role = 'manager' WHERE position = 'Dean';

ALTER TABLE leave_requests
    ADD COLUMN supervisor_status ENUM('pending', 'approved', 'rejected', 'not_required') DEFAULT 'pending' AFTER status,
    ADD COLUMN hr_status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending' AFTER supervisor_status,
    ADD COLUMN hr_id INT NULL AFTER manager_comments,
    ADD COLUMN hr_comments TEXT NULL AFTER hr_id,
    ADD FOREIGN KEY (hr_id) REFERENCES users(id) ON DELETE SET NULL;

-- Backfill existing rows so old single-stage requests remain consistent
UPDATE leave_requests SET supervisor_status = 'approved', hr_status = 'approved' WHERE status = 'approved';
UPDATE leave_requests SET supervisor_status = 'rejected', hr_status = 'rejected' WHERE status = 'rejected';
