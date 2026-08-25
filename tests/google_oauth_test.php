<?php
require_once __DIR__ . '/../src/auth/Auth.php';

function assertContains($haystack, $needle, $message) {
    if (strpos($haystack, $needle) === false) {
        throw new Exception($message);
    }
}

$redirectUrl = Auth::buildGoogleAuthUrl('http://127.0.0.1:8000/api/auth.php?action=google_callback');
assertContains($redirectUrl, 'https://accounts.google.com/o/oauth2/v2/auth', 'Google auth URL should point to Google OAuth endpoint');
assertContains($redirectUrl, 'response_type=code', 'Google auth URL should request an authorization code');
assertContains($redirectUrl, 'scope=openid+email+profile', 'Google auth URL should request the email and profile scopes');

echo "PASS: Google OAuth URL generation works\n";
