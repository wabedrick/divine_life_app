<?php
$dsn = 'mysql:host=127.0.0.1;dbname=divine_life_db;port=3306;charset=utf8mb4';
$user = 'root';
$pass = '';
try {
    $pdo = new PDO($dsn, $user, $pass, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    $stmt = $pdo->query("SHOW COLUMNS FROM users");
    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($cols, JSON_PRETTY_PRINT);
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
