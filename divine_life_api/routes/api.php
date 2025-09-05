<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\RoleController;
use App\Http\Middleware\CheckRole;

Route::post('/register', [RegisterController::class, 'register']);
Route::post('/login', [LoginController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::post('/logout', [LoginController::class, 'logout']);
});

// Role management
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/roles', [RoleController::class, 'index']);

    // Admin-only: assign/revoke roles
    Route::post('/users/{id}/roles', [RoleController::class, 'assign'])->middleware(CheckRole::class . ':admin');
    Route::delete('/users/{id}/roles', [RoleController::class, 'revoke'])->middleware(CheckRole::class . ':admin');
    Route::get('/users/{id}/roles', [RoleController::class, 'show']);
});

// Admin dashboard
Route::get('/admin/dashboard', [App\Http\Controllers\AdminController::class, 'dashboard'])
    ->middleware(['auth:sanctum', App\Http\Middleware\CheckRole::class . ':admin']);
