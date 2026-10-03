<?php
require_once __DIR__ . '/../src/leave/LeaveAttachment.php';

function assertTrue($condition, $message) {
    if (!$condition) {
        throw new Exception($message);
    }
}

// Allowed types map to extensions
assertTrue(LeaveAttachment::ALLOWED_MIME['application/pdf'] === 'pdf', 'PDF should be an allowed type');
assertTrue(LeaveAttachment::ALLOWED_MIME['image/jpeg'] === 'jpg', 'JPEG should be an allowed type');
assertTrue(LeaveAttachment::ALLOWED_MIME['image/png'] === 'png', 'PNG should be an allowed type');
assertTrue(!isset(LeaveAttachment::ALLOWED_MIME['application/x-msdownload']), 'Executables should not be allowed');
assertTrue(!isset(LeaveAttachment::ALLOWED_MIME['text/html']), 'HTML should not be allowed (XSS risk)');

// Size cap is 5 MB
assertTrue(LeaveAttachment::MAX_BYTES === 5242880, 'Max upload size should be 5 MB');

// Filename sanitization strips path traversal and control characters
$clean = new ReflectionMethod('LeaveAttachment', 'sanitizeName');
$clean->setAccessible(true);
assertTrue($clean->invoke(null, '../../etc/passwd') === 'passwd', 'Path traversal should be stripped to basename');
assertTrue($clean->invoke(null, "cert\x00.pdf") === 'cert.pdf', 'Null bytes should be removed');
assertTrue($clean->invoke(null, '') === 'document', 'An empty name should fall back to a default');
assertTrue($clean->invoke(null, 'Medical Cert 2026.pdf') === 'Medical Cert 2026.pdf', 'A normal filename should pass through');

echo "PASS: leave attachment validation allows only safe types/sizes and sanitizes names\n";
