<?php
/**
 * Main Index - Router
 */

require_once __DIR__ . '/config/config.php';

// Simple router
$request_uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
// Collapse accidental double slashes (e.g. from a trailing slash in APP_URL)
$request_uri = preg_replace('#/+#', '/', $request_uri);
$request_method = $_SERVER['REQUEST_METHOD'];

// Reject path traversal attempts before they're used to build filesystem paths
if (strpos($request_uri, '..') !== false) {
    http_response_code(400);
    echo "Bad request";
    exit;
}

// Clean URL -> physical view file, plus who is allowed to load it.
// 'auth' => must be logged in. 'role' => 'admin' restricts to admins,
// 'non-admin' redirects admins elsewhere (they use the admin dashboard instead).
$viewRoutes = [
    '/login'                  => ['file' => 'views/login.html', 'guest' => true],
    '/activate'                => ['file' => 'views/activate.html', 'auth' => true],
    '/confirm-device-change'   => ['file' => 'views/confirm_device_change.html'],
    '/dashboard'               => ['file' => 'views/dashboard.html', 'auth' => true, 'role' => 'non-admin'],
    '/new-request'             => ['file' => 'views/new_request.html', 'auth' => true, 'role' => 'non-admin'],
    '/my-requests'             => ['file' => 'views/my_requests.html', 'auth' => true, 'role' => 'non-admin'],
    '/my-info'                 => ['file' => 'views/my_info.html', 'auth' => true],
    '/settings'                => ['file' => 'views/settings.html', 'auth' => true],
    '/admin'                   => ['file' => 'views/admin.html', 'auth' => true, 'role' => 'admin'],
];

// API routes
if (strpos($request_uri, '/api/') === 0) {
    $api_file = __DIR__ . $request_uri;
    if (pathinfo($api_file, PATHINFO_EXTENSION) === 'php' && file_exists($api_file)) {
        require_once $api_file;
    } else {
        http_response_code(404);
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'message' => 'API endpoint not found']);
    }
}
// View routes (checked before generic static handling since these live outside public/)
elseif (array_key_exists($request_uri, $viewRoutes)) {
    $route = $viewRoutes[$request_uri];

    if (!empty($route['auth']) || !empty($route['guest'])) {
        require_once __DIR__ . '/src/database/Database.php';
        require_once __DIR__ . '/src/auth/Auth.php';

        $isAuthenticated = Auth::isAuthenticated();
        $currentUser = $isAuthenticated ? Auth::getCurrentUser() : null;
        $isAdmin = $currentUser && $currentUser['role'] === 'admin';

        if (!empty($route['guest']) && $isAuthenticated) {
            header('Location: ' . ($isAdmin ? '/admin' : '/dashboard'));
            exit;
        }

        if (!empty($route['auth'])) {
            if (!$isAuthenticated) {
                header('Location: /login');
                exit;
            }
            if ($route['role'] === 'admin' && !$isAdmin) {
                header('Location: /dashboard');
                exit;
            }
            if ($route['role'] === 'non-admin' && $isAdmin) {
                header('Location: /admin');
                exit;
            }
        }
    }

    $file_path = __DIR__ . '/' . $route['file'];
    if (file_exists($file_path)) {
        header('Content-Type: text/html');
        readfile($file_path);
    } else {
        http_response_code(404);
        echo "Page not found";
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
// Default to the dashboard; the route above redirects unauthenticated
// visitors to /login and admins to /admin
else {
    header('Location: /dashboard');
    exit;
}
?>
