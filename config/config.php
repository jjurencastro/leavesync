<?php
/**
 * Application Configuration
 */

// Load environment variables
$env = parse_ini_file(__DIR__ . '/../.env');

// Database Configuration
define('DB_HOST', $env['DB_HOST'] ?? 'localhost');
define('DB_USER', $env['DB_USER'] ?? 'root');
define('DB_PASSWORD', $env['DB_PASSWORD'] ?? '');
define('DB_NAME', $env['DB_NAME'] ?? 'leavesync');
define('DB_PORT', 3306);

// Application Configuration
define('APP_ENV', $env['APP_ENV'] ?? 'production');
define('APP_DEBUG', $env['APP_DEBUG'] === 'true' ?? false);
define('APP_URL', $env['APP_URL'] ?? 'https://localhost:8443');
define('APP_SECRET', $env['APP_SECRET'] ?? '');

// Security Keys
define('ENCRYPTION_KEY', $env['ENCRYPTION_KEY'] ?? '');
define('JWT_SECRET', $env['JWT_SECRET'] ?? '');

// Session Configuration
define('SESSION_LIFETIME', (int)($env['SESSION_LIFETIME'] ?? 3600));
define('SESSION_SECURE', $env['SESSION_SECURE'] === 'true' ?? true);
define('SESSION_HTTPONLY', $env['SESSION_HTTPONLY'] === 'true' ?? true);

// MFA Configuration
define('MFA_ENABLED', $env['MFA_ENABLED'] === 'true' ?? true);
define('MFA_WINDOW', (int)($env['MFA_WINDOW'] ?? 30));

// API Rate Limiting
define('RATE_LIMIT_REQUESTS', (int)($env['RATE_LIMIT_REQUESTS'] ?? 100));
define('RATE_LIMIT_WINDOW', (int)($env['RATE_LIMIT_WINDOW'] ?? 3600));

// Security Headers
header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('X-XSS-Protection: 1; mode=block');
header('Content-Security-Policy: default-src \'self\'; script-src \'self\' \'unsafe-inline\'; style-src \'self\' \'unsafe-inline\'');
header('Referrer-Policy: strict-origin-when-cross-origin');

// Error Reporting
if (APP_DEBUG) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
} else {
    error_reporting(E_ALL & ~E_DEPRECATED & ~E_STRICT);
    ini_set('display_errors', 0);
}

// Timezone
date_default_timezone_set('UTC');

// Session Settings
ini_set('session.cookie_secure', SESSION_SECURE ? 1 : 0);
ini_set('session.cookie_httponly', SESSION_HTTPONLY ? 1 : 0);
ini_set('session.cookie_samesite', 'Strict');
ini_set('session.gc_maxlifetime', SESSION_LIFETIME);

// CORS Configuration
header('Access-Control-Allow-Origin: ' . APP_URL);
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Credentials: true');

// Enable HTTPS enforcement
if (!APP_DEBUG && empty($_SERVER['HTTPS'])) {
    header('Location: https://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI']);
    exit;
}

?>
