<?php
include 'config.php';
include 'email_config.php';

$data = json_decode(file_get_contents('php://input'), true);

$email = isset($data['email']) ? $data['email'] : '';
$password = isset($data['password']) ? $data['password'] : '';

if (empty($email) || empty($password)) {
    echo json_encode(['success' => false, 'message' => 'Email and password required']);
    exit;
}

// Domain validation for UiTM Jasin students only
if (!preg_match('/^\d{10}@student\.uitm\.edu\.my$/', $email)) {
    echo json_encode(['success' => false, 'message' => 'Only UiTM Jasin student emails are allowed (10-digit@student.uitm.edu.my)']);
    exit;
}

// Check user
$stmt = $conn->prepare("SELECT id FROM users WHERE email = ? AND password = ?");
$stmt->bind_param("ss", $email, $password);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows == 0) {
    echo json_encode(['success' => false, 'message' => 'Invalid credentials']);
    exit;
}

// Generate OTP
$otp = rand(100000, 999999);
$expiry = date('Y-m-d H:i:s', strtotime('+10 minutes'));

// Update OTP
$stmt = $conn->prepare("UPDATE users SET otp = ?, otp_expiry = ? WHERE email = ?");
$stmt->bind_param("sss", $otp, $expiry, $email);

if ($stmt->execute()) {
    // Send OTP via email
    $emailResult = EmailConfig::sendOTP($email, $otp);

    if ($emailResult['success']) {
        echo json_encode(['success' => true, 'message' => $emailResult['message']]);
    } else {
        echo json_encode(['success' => false, 'message' => isset($emailResult['message']) ? $emailResult['message'] : 'Failed to send OTP email']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Failed to generate OTP']);
}

$stmt->close();
$conn->close();
?>