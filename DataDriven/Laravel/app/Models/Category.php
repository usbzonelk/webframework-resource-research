<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    // Define the table associated with the model
    protected $table = 'categories';

    // Define the fillable fields (mass assignment)
    protected $fillable = ['name', 'id']; // Fields that can be mass-assigned

    // Set custom table primary key
    protected $primaryKey = 'id'; // Use the 'id' column as the primary key

    // Specify whether the primary key is auto-incrementing
    public $incrementing = true; // The custom 'id' is not auto-incrementing

    // Disable timestamps if not using them (optional)
    public $timestamps = false;

    // Add validation rules if needed (typically in controllers or form requests)
    public static $rules = [
        'name' => 'required|max:150',
        'id' => 'required|unique:categories,id', // The custom 'id' is unique
    ];

    public function posts()
    {
        return $this->belongsToMany(Post::class, 'category_post', 'category', 'post');
    }
}
