<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class TestController extends Controller
{
    /**
     * Return a test message as JSON response.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function test()
    {
        
        return response()->json([
            'message' => 'Hello, World!'
        ]);
    }
}
