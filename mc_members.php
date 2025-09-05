<?php
// mc_members.php

header('Content-Type: application/json');

// --- DATABASE CONNECTION ---
$servername = "localhost"; // Change if needed
$username = "your_db_user"; // Change to your DB username
$password = "your_db_password"; // Change to your DB password
$dbname = "your_db_name"; // Change to your DB name

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed']);
    exit;
}

// --- ADD MEMBER ACTION ---
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'add_member') {
    // Get data from POST
    $name = $_POST['name'] ?? '';
    $email = $_POST['email'] ?? '';
    $phone = $_POST['phone'] ?? '';
    $isActive = $_POST['isActive'] ?? '1';
    $joinDate = $_POST['joinDate'] ?? date('Y-m-d');
    // If joinDate is in ISO format, extract the date part
    if (strpos($joinDate, 'T') !== false) {
        $joinDate = substr($joinDate, 0, 10);
    }
    $gender = $_POST['gender'] ?? 'Other';
    $mcName = $_POST['mcName'] ?? '';
    $dob = $_POST['dob'] ?? '';
    $dlm_member = $_POST['dlm_member'] ?? '0';

    // Validate required fields
    if (empty($name) || empty($mcName)) {
        http_response_code(400);
        echo json_encode(['error' => 'Name and MC Name are required']);
        exit;
    }

    // Prepare and execute insert (do NOT include id)
    $stmt = $conn->prepare("INSERT INTO mc_members (name, email, phone, isActive, joinDate, gender, mcName, dob, dlm_member) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
    if (!$stmt) {
        http_response_code(500);
        echo json_encode(['error' => 'Prepare failed: ' . $conn->error]);
        exit;
    }
    $stmt->bind_param("sssssssss", $name, $email, $phone, $isActive, $joinDate, $gender, $mcName, $dob, $dlm_member);

    if ($stmt->execute()) {
        $newId = $conn->insert_id;
        echo json_encode(['id' => $newId]);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to add member: ' . $stmt->error]);
    }
    $stmt->close();
    $conn->close();
    exit;
}

// --- DEFAULT RESPONSE FOR UNSUPPORTED ACTIONS ---
http_response_code(400);
echo json_encode(['error' => 'Invalid request or action']);
$conn->close();
exit;
?> 