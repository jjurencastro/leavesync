<?php
/**
 * Migration runner - executes pending SQL migrations
 * This is a utility endpoint for development/deployment
 */

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../src/database/Database.php';
require_once __DIR__ . '/../src/auth/Auth.php';

header('Content-Type: application/json');

// Only admins can run migrations
$user = Auth::getCurrentUser();
if (!$user || $user['role'] !== 'admin') {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // Get list of migration files
    $migrationDir = __DIR__ . '/../src/database';
    $files = glob($migrationDir . '/migration_*.sql');
    
    if (empty($files)) {
        echo json_encode(['success' => true, 'message' => 'No migrations found', 'migrated' => 0]);
        exit;
    }
    
    $migrated = 0;
    $errors = [];
    
    foreach ($files as $file) {
        $sql = file_get_contents($file);
        if (!$sql) {
            $errors[] = basename($file) . ': Could not read file';
            continue;
        }
        
        try {
            if ($conn->query($sql)) {
                $migrated++;
            } else {
                // Check if error is "already exists" which means already migrated
                if (strpos($conn->error, 'already exists') !== false || 
                    strpos($conn->error, 'Duplicate') !== false) {
                    $migrated++;
                } else {
                    $errors[] = basename($file) . ': ' . $conn->error;
                }
            }
        } catch (Exception $e) {
            $errors[] = basename($file) . ': ' . $e->getMessage();
        }
    }
    
    echo json_encode([
        'success' => true,
        'migrated' => $migrated,
        'total' => count($files),
        'errors' => $errors
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>
