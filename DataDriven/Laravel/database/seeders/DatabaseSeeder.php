<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        // Call the individual seeders
        $this->call([
            AuthorSeeder::class,
            CategorySeeder::class,
            PostSeeder::class, // If you're seeding posts as well
        ]);
    }
}
