<?php
include 'config.php';

$data = json_decode(file_get_contents('php://input'), true);
$email = $data['email'] ?? '';
$otp = $data['otp'] ?? '';

if (empty($email) || empty($otp)) {
    die(json_encode(['success' => false, 'message' => 'Missing data']));
}

// Check if OTP matches and is not expired
$stmt = $conn->prepare("SELECT id FROM users WHERE email = ? AND otp = ? AND otp_expiry > NOW()");
$stmt->bind_param("ss", $email, $otp);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    // Verification successful: Clear OTP and set verified flag
    $update = $conn->prepare("UPDATE users SET otp = NULL, otp_expiry = NULL, email_verified = 1 WHERE email = ?");
    $update->bind_param("s", $email);
    $update->execute();
    
    echo json_encode(['success' => true, 'message' => 'Account verified!']);
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid or expired OTP code.']);
}

$stmt->close();
$conn->close();
?>