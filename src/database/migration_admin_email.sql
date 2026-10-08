-- Update the existing administrator account to the operational email address.
UPDATE users
SET email = 'leavesync.noreply@gmail.com'
WHERE username = 'admin'
  AND role = 'admin'
  AND email = 'admin@thelewiscollege.edu.ph';
