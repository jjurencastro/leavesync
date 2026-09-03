-- Migration: bind passkeys to the device they were registered on.
-- Existing credentials predate device binding and can't be verified against it,
-- so they are force-invalidated here; every approver must re-register a passkey per device.

ALTER TABLE webauthn_credentials
    ADD COLUMN device_fingerprint_hash VARCHAR(64) AFTER label,
    ADD COLUMN device_label VARCHAR(100) AFTER device_fingerprint_hash;

DELETE FROM webauthn_credentials;
