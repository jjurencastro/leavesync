<?php
/**
 * Main Index - Router
 */

require_once __DIR__ . '/config/config.php';

// Simple router
$request_uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$request_method = $_SERVER['REQUEST_METHOD'];

// API routes
if (strpos($request_uri, '/api/') === 0) {
    $api_file = __DIR__ . $request_uri . '.php';
    if (file_exists($api_file)) {
        require_once $api_file;
    } else {
        http_response_code(404);
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'message' => 'API endpoint not found']);
    }
} 
// Static files
elseif (in_array(pathinfo($request_uri, PATHINFO_EXTENSION), ['css', 'js', 'html', 'png', 'jpg', 'jpeg', 'gif', 'svg', 'ico'])) {
    $file_path = __DIR__ . '/public' . $request_uri;
    if (file_exists($file_path)) {
        $mime_types = [
            'css' => 'text/css',
            'js' => 'application/javascript',
            'html' => 'text/html',
            'png' => 'image/png',
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'gif' => 'image/gif',
            'svg' => 'image/svg+xml',
            'ico' => 'image/x-icon'
        ];
        $ext = pathinfo($file_path, PATHINFO_EXTENSION);
        header('Content-Type: ' . ($mime_types[$ext] ?? 'application/octet-stream'));
        readfile($file_path);
    } else {
        http_response_code(404);
        echo "File not found";
    }
}
// View routes
elseif (in_array($request_uri, ['/views/login.html', '/views/register.html', '/views/dashboard.html', '/views/new_request.html', '/views/settings.html'])) {
    $file_path = __DIR__ . $request_uri;
    if (file_exists($file_path)) {
        header('Content-Type: text/html');
        readfile($file_path);
    } else {
        http_response_code(404);
        echo "Page not found";
    }
}
// Default to login
else {
    header('Location: /views/login.html');
    exit;
}
?>
