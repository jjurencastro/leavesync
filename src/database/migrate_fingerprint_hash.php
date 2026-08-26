<?php
/**
 * Recomputes device_fingerprints.fingerprint_hash to exclude IP address,
 * matching the updated DeviceFingerprint::buildHashData(). Run this once after
 * deploying that change so existing trusted devices keep matching instead of
 * being forced through a "device changed" re-verification.
 *
 * Run in the same environment as the app (so DB_HOST/etc. env vars resolve):
 *   php src/database/migrate_fingerprint_hash.php
 */

require_once __DIR__ . '/../../config/config.php';
require_once __DIR__ . '/Database.php';

$db = Database::getInstance();
$rows = $db->getResults("SELECT id, device_info FROM device_fingerprints");

$updated = 0;
foreach ($rows as $row) {
    $info = json_decode($row['device_info'], true);
    if (!is_array($info)) {
        continue;
    }

    $hashData = [
        'user_agent' => $info['user_agent'] ?? '',
        'accept_language' => $info['accept_language'] ?? '',
        'accept_encoding' => $info['accept_encoding'] ?? '',
        'browser' => $info['browser'] ?? '',
        'os' => $info['os'] ?? '',
    ];
    $newHash = hash('sha256', json_encode($hashData));

    $db->execute("UPDATE device_fingerprints SET fingerprint_hash = ? WHERE id = ?", [$newHash, $row['id']]);
    $updated++;
}

echo "Recomputed fingerprint_hash for {$updated} device(s).\n";
