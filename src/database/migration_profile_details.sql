-- Migration: optional, employee-entered profile details (contact, address, emergency contact).

CREATE TABLE IF NOT EXISTS employee_profile_details (
    user_id INT PRIMARY KEY,
    nickname VARCHAR(50) NULL,
    contact_number VARCHAR(25) NULL,
    address VARCHAR(255) NULL,
    date_of_birth DATE NULL,
    civil_status VARCHAR(20) NULL,
    emergency_contact_name VARCHAR(100) NULL,
    emergency_contact_relationship VARCHAR(50) NULL,
    emergency_contact_number VARCHAR(25) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
