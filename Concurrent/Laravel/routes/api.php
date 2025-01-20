<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ConcurrentController;

Route::get('/read', [ConcurrentController::class, 'readFile']);
