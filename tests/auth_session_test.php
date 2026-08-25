<?php
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../src/database/Database.php';
require_once __DIR__ . '/../src/auth/Auth.php';
require_once __DIR__ . '/../src/security/DeviceFingerprint.php';
require_once __DIR__ . '/../src/security/DigitalSignature.php';

function assertTrue($condition, $message) {
    if (!$condition) {
        throw new Exception($message);
    }
}

$email = 'session-test-' . uniqid() . '@example.com';
$username = 'sessiontest' . uniqid();

$registerResult = Auth::register([
    'username' => $username,
    'email' => $email,
    'password' => 'password123',
    'full_name' => 'Session Tester',
    'department' => 'IT'
]);
assertTrue($registerResult['success'] === true, 'Registration should succeed for the session test');

$loginResult = Auth::login($email, 'password123');
assertTrue($loginResult['success'] === true, 'Login should succeed for the session test');

$_COOKIE['auth_token'] = $loginResult['token'];
$currentUser = Auth::getCurrentUser();
assertTrue(!empty($currentUser), 'Authenticated user should be returned after login');

echo "PASS: session-based authentication works\n";
