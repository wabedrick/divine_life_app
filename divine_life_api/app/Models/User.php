<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'username',
        'email',
        'password',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Roles relationship
     */
    public function roles()
    {
        return $this->belongsToMany(Role::class);
    }

    /**
     * Check if user has a role (string or array)
     */
    public function hasRole($role): bool
    {
        if (is_array($role)) {
            return $this->roles()->whereIn('name', $role)->exists();
        }

        return $this->roles()->where('name', $role)->exists();
    }

    /**
     * Assign a role to the user
     */
    public function assignRole($role): void
    {
        if (is_string($role)) {
            $role = Role::firstOrCreate(['name' => $role]);
        }

        $this->roles()->syncWithoutDetaching([$role->id]);
    }

    /**
     * Remove role
     */
    public function removeRole($role): void
    {
        if (is_string($role)) {
            $role = Role::where('name', $role)->first();
            if (!$role) {
                return;
            }
        }

        $this->roles()->detach($role->id);
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }
}
