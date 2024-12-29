<?php

// database/seeders/PostSeeder.php

namespace Database\Seeders;

use App\Models\Post;
use App\Models\Author;
use App\Models\Category;
use Illuminate\Database\Seeder;

class PostSeeder extends Seeder
{
    public function run()
    {
        $post = Post::create([
            'title' => 'Sample Post',
            'slug' => 'sample-post',
            'content' => 'This is the content of the post.',
            'postStatus' => 'Published'
        ]);

        // Attach authors and categories
        $post->authors()->attach([1]); // Assuming authors with ID 1 and 2 exist
        $post->categories()->attach([1, 2]); // Assuming categories with ID 1 and 2 exist
    }
}
