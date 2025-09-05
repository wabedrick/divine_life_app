<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckRole
{
    /**
     * Handle an incoming request.
     * Accepts roles as pipe-delimited string or array in the middleware parameter.
     */
    public function handle(Request $request, Closure $next, $roles = null)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        $allowed = [];
        if (is_string($roles)) {
            $allowed = explode('|', $roles);
        } elseif (is_array($roles)) {
            $allowed = $roles;
        }

        if (empty($allowed)) {
            return $next($request);
        }

        if (!$user->hasRole($allowed)) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        return $next($request);
    }
}
