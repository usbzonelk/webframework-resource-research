<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PostController;
use App\Http\Controllers\AuthorController;
use App\Http\Controllers\CommentController;
/*
Route::get('/posts', [PostController::class, 'get']);
Route::get('/posts/popular', [PostController::class, 'popularPosts']);
Route::get('/posts/search', [PostController::class, 'search']);
Route::get('/posts/sort-by-date', [PostController::class, 'sortByDate']);
Route::post('/posts/create', [PostController::class, 'create']);
Route::put('/posts/status-update', [PostController::class, 'bulkStatusUpdate']);
Route::put('/posts/edit', [PostController::class, 'edit']);
*/
Route::post('/authors/get-posts', [AuthorController::class, 'getPosts']);
/*
Route::post('/comments/create-bulk', [CommentController::class, 'createBulk']);
Route::post('/comments/delete-bulk', [CommentController::class, 'deleteBulk']);
*/