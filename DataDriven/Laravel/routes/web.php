<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\TestController;

// Example route for testing
Route::get('/test', [TestController::class, 'test']);
