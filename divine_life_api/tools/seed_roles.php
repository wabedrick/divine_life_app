<?php
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\Role;

Role::firstOrCreate(['name' => 'admin'], ['label' => 'Administrator']);
Role::firstOrCreate(['name' => 'member'], ['label' => 'Member']);
Role::firstOrCreate(['name' => 'mc_leader'], ['label' => 'MC Leader']);
echo json_encode(Role::all()->pluck('name')->toArray());
