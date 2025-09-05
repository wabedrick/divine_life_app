<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Role;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function dashboard(Request $request)
    {
        $totalUsers = User::count();
        $totalRoles = Role::count();

        $usersPerRole = Role::withCount('users')->get()->mapWithKeys(function ($r) {
            return [$r->name => $r->users_count];
        });

        return response()->json([
            'total_users' => $totalUsers,
            'total_roles' => $totalRoles,
            'users_per_role' => $usersPerRole,
        ]);
    }
}
