-- Add 'escalated_to_hr' status to supervisor_status ENUM to track when HR approves as backup
ALTER TABLE leave_requests MODIFY COLUMN supervisor_status ENUM('pending', 'approved', 'rejected', 'not_required', 'escalated_to_hr') DEFAULT 'pending';
