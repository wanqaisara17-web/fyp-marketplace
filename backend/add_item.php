<?php
include 'config.php';

$data = json_decode(file_get_contents("php://input"), true);

$item_name = $data['item_name'] ?? '';
$item_price = $data['item_price'] ?? '';
$description = $data['description'] ?? '';
$category = $data['category'] ?? '';

if (
    empty($item_name) ||
    empty($item_price) ||
    empty($description) ||
    empty($category)
) {
    echo json_encode([
        "success" => false,
        "message" => "All fields are required"
    ]);
    exit;
}

$stmt = $conn->prepare(
    "INSERT INTO items (item_name, item_price, description, category)
     VALUES (?, ?, ?, ?)"
);

$stmt->bind_param(
    "sdss",
    $item_name,
    $item_price,
    $description,
    $category
);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Item added successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to add item"
    ]);
}

$stmt->close();
$conn->close();
?>