<?php
include 'config.php';

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

// Check if email exists
$stmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    echo json_encode(['success' => false, 'message' => 'Email already exists']);
    exit;
}

// Insert user
$stmt = $conn->prepare("INSERT INTO users (email, password, name, email_verified) VALUES (?, ?, ?, 0)");
$name = '';
$stmt->bind_param("sss", $email, $password, $name);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Registration successful']);
} else {
    echo json_encode(['success' => false, 'message' => 'Registration failed']);
}

$stmt->close();
$conn->close();
?>