<?php
/**
 * Autoloader - Include required files
 */

spl_autoload_register(function ($class) {
    $prefix = 'LeaveSync\\';
    $base_dir = __DIR__ . '/src/';

    // Check if class uses namespace
    $len = strlen($prefix);
    if (strncmp($prefix, $class, $len) !== 0) {
        return;
    }

    $relative_class = substr($class, $len);
    $file = $base_dir . str_replace('\\', '/', $relative_class) . '.php';

    if (file_exists($file)) {
        require $file;
    }
});

// Include core classes without namespace
require_once __DIR__ . '/src/database/Database.php';
require_once __DIR__ . '/src/auth/Auth.php';
require_once __DIR__ . '/src/auth/MFA.php';
require_once __DIR__ . '/src/security/DeviceFingerprint.php';
require_once __DIR__ . '/src/security/DigitalSignature.php';
?>
