<?php

namespace App\Http\Controllers;

use App\Models\Role;
use App\Models\User;
use Illuminate\Http\Request;

class RoleController extends Controller
{
    public function index()
    {
        return response()->json(Role::all());
    }

    public function assign(Request $request, $userId)
    {
        $request->validate(['role' => 'required|string']);
        $user = User::findOrFail($userId);
        $user->assignRole($request->input('role'));
        return response()->json(['message' => 'Role assigned']);
    }

    public function revoke(Request $request, $userId)
    {
        $request->validate(['role' => 'required|string']);
        $user = User::findOrFail($userId);
        $user->removeRole($request->input('role'));
        return response()->json(['message' => 'Role revoked']);
    }

    public function show($userId)
    {
        $user = User::findOrFail($userId);
        return response()->json(['user_id' => $user->id, 'email' => $user->email, 'roles' => $user->roles()->pluck('name')]);
    }
}
