<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\User;

// Change this email to the user you want to make admin
$email = $argv[1] ?? 'testuser3@example.com';

$user = User::where('email', $email)->first();
if (!$user) {
    echo json_encode(['error' => 'User not found']);
    exit(1);
}

$user->assignRole('admin');

echo json_encode(['user_id' => $user->id, 'email' => $user->email, 'roles' => $user->roles()->pluck('name')]);
