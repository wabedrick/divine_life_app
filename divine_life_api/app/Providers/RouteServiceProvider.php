<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Route;

class RouteServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Load API routes
        Route::prefix('api')
            ->middleware('api')
            ->group(base_path('routes/api.php'));

        // Load web routes
        Route::middleware('web')
            ->group(base_path('routes/web.php'));
    }
}
