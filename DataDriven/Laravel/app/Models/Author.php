<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Author extends Model
{
    use HasFactory;

    protected $table = 'authors';

    protected $fillable = ['name', 'email', 'id'];

    protected $primaryKey = 'id';

    public $incrementing = true;

    public $timestamps = false;

    public static $rules = [
        'name' => 'required|max:150',
        'email' => 'required|email|unique:authors,email',
        'id' => 'required|unique:authors,id',
    ];
    public function posts()
    {
        return $this->belongsToMany(Post::class, 'author_post', 'author', 'post');
    }
}
