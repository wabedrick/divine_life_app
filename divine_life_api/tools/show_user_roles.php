<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\User;

$email = $argv[1] ?? null;
if (!$email) {
    echo "Usage: php show_user_roles.php user@example.com\n";
    exit(1);
}

$user = User::where('email', $email)->first();
if (!$user) {
    echo json_encode(['error' => 'User not found']);
    exit(1);
}

echo json_encode(['user_id' => $user->id, 'email' => $user->email, 'roles' => $user->roles()->pluck('name')]);
