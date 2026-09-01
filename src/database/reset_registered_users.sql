-- DESTRUCTIVE ONE-OFF RESET
-- Preserves only the existing administrator at users.id = 1 and the leave_types catalog.
-- Run on the target database only after taking a backup and stopping application traffic.

DELIMITER //

DROP PROCEDURE IF EXISTS reset_registered_users //

CREATE PROCEDURE reset_registered_users()
BEGIN
    DECLARE preserved_admins INT DEFAULT 0;
    DECLARE remaining_users INT DEFAULT 0;
    DECLARE next_user_id INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT COUNT(*) INTO preserved_admins
    FROM users
    WHERE id = 1 AND role = 'admin';

    IF preserved_admins <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Reset aborted: users.id = 1 must be the preserved administrator.';
    END IF;

    START TRANSACTION;

    -- Delete all records owned by non-admin registrations. Administrator records remain intact.
    DELETE FROM mfa_secrets WHERE user_id <> 1;
    DELETE FROM webauthn_challenges WHERE user_id <> 1;
    DELETE FROM webauthn_credentials WHERE user_id <> 1;
    DELETE FROM sessions WHERE user_id <> 1;
    DELETE FROM device_fingerprints WHERE user_id <> 1;
    DELETE FROM notifications WHERE user_id <> 1;
    DELETE FROM leave_balances WHERE user_id <> 1;
    DELETE FROM device_change_requests WHERE user_id <> 1;

    -- Approval evidence for deleted leave requests must be removed even when an admin signed it.
    DELETE digital_signatures
    FROM digital_signatures
    JOIN leave_requests ON leave_requests.id = digital_signatures.document_id
    WHERE digital_signatures.document_type = 'leave_request'
      AND leave_requests.user_id <> 1;

    DELETE FROM digital_signatures WHERE signer_id <> 1;
    DELETE FROM leave_requests WHERE user_id <> 1;
    DELETE FROM audit_log WHERE user_id IS NULL OR user_id <> 1;
    DELETE FROM users WHERE id <> 1;

    UPDATE user_id_sequence SET next_id = 2 WHERE id = 1;
    INSERT INTO user_id_sequence (id, next_id)
    SELECT 1, 2 WHERE NOT EXISTS (SELECT 1 FROM user_id_sequence WHERE id = 1);

    SELECT COUNT(*) INTO remaining_users FROM users;
    SELECT next_id INTO next_user_id FROM user_id_sequence WHERE id = 1;

    IF remaining_users <> 1 OR next_user_id <> 2 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Reset verification failed; no changes were committed.';
    END IF;

    COMMIT;
END //

DELIMITER ;

-- Execute once, then remove the procedure from the database:
-- CALL reset_registered_users();
-- ALTER TABLE users AUTO_INCREMENT = 2;
-- DROP PROCEDURE reset_registered_users;

-- Post-reset checks:
-- SELECT id, username, email, role FROM users;
-- SELECT next_id FROM user_id_sequence WHERE id = 1;
-- SELECT id, name, days_per_year FROM leave_types ORDER BY id;