-- Add assigned_approver_id to device_change_requests for backup approver support
ALTER TABLE device_change_requests 
ADD COLUMN assigned_approver_id INT NULL,
ADD FOREIGN KEY (assigned_approver_id) REFERENCES users(id) ON DELETE SET NULL,
ADD INDEX idx_assigned_approver_id (assigned_approver_id);
