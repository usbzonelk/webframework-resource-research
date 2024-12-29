<?php

// database/seeders/AuthorSeeder.php

namespace Database\Seeders;

use App\Models\Author;
use Illuminate\Database\Seeder;

class AuthorSeeder extends Seeder
{
    public function run()
    {
        // Creating some sample authors
        Author::create([
            'name' => 'John Doe',
            'email' => 'john.doe@example.com',
        ]);

        Author::create([
            'name' => 'Jane Smith',
            'email' => 'jane.smith@example.com',
        ]);

        Author::create([
            'name' => 'Alice Johnson',
            'email' => 'alice.johnson@example.com',
        ]);
    }
}
