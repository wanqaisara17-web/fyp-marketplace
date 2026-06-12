<?php
include 'config.php';

$sql = "SELECT id, item_name, item_price, description, category, created_at 
        FROM items 
        ORDER BY id DESC";

$result = $conn->query($sql);

$items = array();

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $items[] = $row;
    }
}

echo json_encode([
    "success" => true,
    "items" => $items
]);

$conn->close();
?>