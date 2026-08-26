-- Adds the `position` (job title) column, separate from the `role` permission tier.
-- Run via the same railway ssh + mysqli approach used for other production migrations,
-- since the deploy image has no `mysql` CLI.

ALTER TABLE users ADD COLUMN position VARCHAR(50) AFTER department;
