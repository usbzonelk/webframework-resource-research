<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('posts', function (Blueprint $table) {
            $table->id(); // Auto-incrementing primary key
            $table->string('title', 200); // Title (max length 200)
            $table->string('slug')->unique(); // Unique Slug
            $table->text('content'); // Post content
            $table->enum('postStatus', ['Published', 'Draft'])->default('Published'); // Enum for post status
            $table->timestamp('lastUpdated')->useCurrent(); // Timestamp for 'last_updated'
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('posts');
    }
};
