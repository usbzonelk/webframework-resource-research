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
        Schema::create('author_post', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('post');
            $table->unsignedBigInteger('author');
            $table->timestamps();

            // Foreign key constraints
            $table->foreign('post')->references('id')->on('posts')->onDelete('cascade');
            $table->foreign('author')->references('id')->on('authors')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('author_post');
    }
};
