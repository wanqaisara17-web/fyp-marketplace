<?php
// 1. Set Timezone for Malaysia (Ensures OTP expiry works correctly)
date_default_timezone_set('Asia/Kuala_Lumpur');

// 2. Comprehensive CORS Headers for Chrome
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header('Content-Type: application/json');

// 3. Handle Chrome's Preflight (OPTIONS) Request
// If the request is OPTIONS, we stop here and return a 200 OK status.
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 4. Database Connection
$host = 'localhost';
$db = 'fyp_marketplace';
$user = 'root';
$pass = '';

$conn = new mysqli($host, $user, $pass, $db);

// 5. Check Connection
if ($conn->connect_error) {
    // Return error as JSON so Flutter can read it
    die(json_encode([
        'success' => false, 
        'message' => 'Database connection failed: ' . $conn->connect_error
    ]));
}
?>