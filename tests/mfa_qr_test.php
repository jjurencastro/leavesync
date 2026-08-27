<?php
require_once __DIR__ . '/../src/auth/MFA.php';

$url = MFA::getQRCodeURL('JBSWY3DPEHPK3PXP', 'user@example.com', 'LeaveSync');

if (strpos($url, '+') !== false) {
    fwrite(STDERR, "FAIL: otpauth URL should use percent encoding, not '+' in label encoding\n");
    exit(1);
}

if (strpos($url, 'otpauth://totp/') !== 0) {
    fwrite(STDERR, "FAIL: malformed otpauth URL\n");
    exit(1);
}

echo "PASS: MFA QR URL is valid for authenticator apps\n";
