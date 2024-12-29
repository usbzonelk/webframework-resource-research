
/@**
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCategoriesTable extends Migration
{
    public function up()
    {
        Schema::create('categories', function (Blueprint $table) {
            $table->id(); // Auto-incrementing primary key
            $table->string('name', 150)->unique(); // 'name' column with max length of 150
        });
    }

    public function down()
    {
        Schema::dropIfExists('categories');
    }
}
