<?php
require_once __DIR__ . '/../src/security/DeviceFingerprint.php';
require_once __DIR__ . '/../src/security/DigitalSignature.php';

function assertTrue($condition, $message) {
    if (!$condition) {
        throw new Exception($message);
    }
}

$deviceData = [
    'screen_resolution' => '1920x1080',
    'timezone' => 'UTC',
    'language' => 'en-US',
    'platform' => 'Linux'
];

$fingerprintA = DeviceFingerprint::generateFromData($deviceData);
$fingerprintB = DeviceFingerprint::generateFromData($deviceData);
assertTrue($fingerprintA === $fingerprintB, 'Device fingerprint should be deterministic for the same data');

$keyPair = DigitalSignature::generateKeyPair();
assertTrue(!empty($keyPair['public_key']) && !empty($keyPair['private_key']), 'Key pair generation should return public and private keys');

$message = 'approval-123';
$signature = DigitalSignature::sign($message, $keyPair['private_key']);
assertTrue(DigitalSignature::verify($message, $signature, $keyPair['public_key']), 'Signature verification should succeed for a valid key pair');

echo "PASS: device fingerprint and digital signature checks work\n";
