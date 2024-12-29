<?php

// app/Models/Comment.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Comment extends Model
{
    use HasFactory;

    // Define the table associated with the model
    protected $table = 'comments';

    // Define the fillable fields (mass assignment)
    protected $fillable = ['authorName', 'id', 'content', 'lastUpdated', 'post'];

    // Set custom table primary key
    protected $primaryKey = 'id'; // Use 'id' column as the primary key

    // Specify whether the primary key is auto-incrementing
    public $incrementing = true; // Custom 'id' is not auto-incrementing

    // Disable timestamps if not using them (optional)
    public $timestamps = false;

    // Add validation rules if needed (typically in controllers or form requests)
    public static $rules = [
        'authorName' => 'required|max:50',
        'id' => 'required|unique:comments,id', // The custom 'id' is unique
        'content' => 'required',
        'lastUpdated' => 'nullable|date',
        'post' => 'required|exists:posts,id', // Foreign key validation for 'post_id'
    ];

    // Define the relationship between Comment and Post (Comment belongs to Post)
    public function post()
    {
        return $this->belongsTo(Post::class, 'post');
    }
}
