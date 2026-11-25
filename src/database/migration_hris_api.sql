CREATE TABLE IF NOT EXISTS hris_api_rate_limit (
    id TINYINT PRIMARY KEY,
    window_start BIGINT NOT NULL,
    request_count INT UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
