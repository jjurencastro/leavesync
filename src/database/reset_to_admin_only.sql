-- Wipes all data except admin account(s) and reference data (leave_types),
-- then renumbers remaining users so the first admin becomes id 1, the next
-- admin (if any) becomes id 2, etc., and the next new registration continues from there.
-- Run with: mysql -h "$MYSQLHOST" -P "$MYSQLPORT" -u "$MYSQLUSER" -p"$MYSQLPASSWORD" "$MYSQLDATABASE" < src/database/reset_to_admin_only.sql

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE sessions;
TRUNCATE TABLE device_fingerprints;
TRUNCATE TABLE device_change_requests;
TRUNCATE TABLE mfa_secrets;
TRUNCATE TABLE leave_requests;
TRUNCATE TABLE leave_balances;
TRUNCATE TABLE notifications;
TRUNCATE TABLE audit_log;
TRUNCATE TABLE digital_signatures;

DELETE FROM users WHERE role <> 'admin';
UPDATE users SET supervisor_id = NULL;

-- Renumber remaining admins to 1, 2, 3... in a collision-safe two-pass shift
SET @rownum := 0;
CREATE TEMPORARY TABLE id_map AS
SELECT id AS old_id, (@rownum := @rownum + 1) AS new_id
FROM users
ORDER BY id;

UPDATE users u JOIN id_map m ON u.id = m.old_id SET u.id = m.new_id + 1000000;
UPDATE users SET id = id - 1000000;
DROP TEMPORARY TABLE id_map;

SET @next_id := (SELECT COALESCE(MAX(id), 0) + 1 FROM users);

SET @sql := CONCAT('ALTER TABLE users AUTO_INCREMENT = ', @next_id);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE user_id_sequence SET next_id = @next_id WHERE id = 1;

SET FOREIGN_KEY_CHECKS = 1;
