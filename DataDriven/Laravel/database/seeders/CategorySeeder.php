<?php

// database/seeders/CategorySeeder.php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run()
    {
        // Creating some sample categories
        Category::create([
            'name' => 'Technology',
        ]);

        Category::create([
            'name' => 'Health',
        ]);

        Category::create([
            'name' => 'Lifestyle',
        ]);
    }
}
