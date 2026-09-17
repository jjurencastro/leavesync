-- Migration: mark previously rejected supervisor decisions as terminal.
-- Run once against databases affected before the dean-rejection fix.
UPDATE leave_requests
SET supervisor_status = 'rejected', hr_status = 'rejected'
WHERE status = 'rejected'
  AND (supervisor_status <> 'rejected' OR hr_status <> 'rejected');