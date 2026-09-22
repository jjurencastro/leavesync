-- Migration: store the HTTPS profile picture URL returned by Google OAuth.

ALTER TABLE users
    ADD COLUMN profile_picture_url VARCHAR(2048) NULL AFTER device_fingerprint;