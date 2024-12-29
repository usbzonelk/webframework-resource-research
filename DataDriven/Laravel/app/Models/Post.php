<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    use HasFactory;

    protected $table = 'posts';

    protected $fillable = ['title', 'slug', 'content', 'postStatus'];

    public $incrementing = true;

    public $timestamps = false;

    public function authors()
    {
        return $this->belongsToMany(Author::class, 'author_post', 'post', 'author');
    }


    public function categories()
    {
        return $this->belongsToMany(Category::class, 'category_post', 'post', 'category');
    }

    public static function boot()
    {
        parent::boot();
    }
}
