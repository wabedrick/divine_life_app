<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // If table has `name` column, ensure `username` has values and drop `name`.
        if (Schema::hasColumn('users', 'name')) {
            // If username column doesn't exist, create it nullable first.
            if (!Schema::hasColumn('users', 'username')) {
                Schema::table('users', function (Blueprint $table) {
                    $table->string('username')->nullable();
                });
            }

            // Copy name -> username for rows where username is null or empty
            DB::table('users')->where(function ($q) {
                $q->whereNull('username')->orWhere('username', '');
            })->update(['username' => DB::raw('name')]);

            // Make sure there are no null usernames; if there are still nulls, set a default
            DB::table('users')->whereNull('username')->update(['username' => 'user_' . time()]);

            // Drop the old name column if it exists
            if (Schema::hasColumn('users', 'name')) {
                Schema::table('users', function (Blueprint $table) {
                    $table->dropColumn('name');
                });
            }

            // If username was created nullable, make sure it's not nullable by recreating the column
            // Some DBs require doctrine/dbal to change column attributes; to avoid that we leave it as-is
        }
    }

    public function down(): void
    {
        if (!Schema::hasColumn('users', 'name') && Schema::hasColumn('users', 'username')) {
            Schema::table('users', function (Blueprint $table) {
                $table->string('name')->nullable();
            });

            DB::table('users')->whereNull('name')->update(['name' => DB::raw('username')]);

            Schema::table('users', function (Blueprint $table) {
                $table->string('name')->nullable(false);
                $table->dropColumn('username');
            });
        }
    }
};
