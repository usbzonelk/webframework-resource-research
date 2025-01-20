<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Category;
use Illuminate\Support\Facades\Concurrency;
use Illuminate\Support\Facades\DB;

class CatController extends Controller
{
    public function newComments(Request $request)
    {
        set_time_limit(0);

        $commentsData = $request->input('cats', []);
        if (!is_array($commentsData) || count($commentsData) < 1) {
            return response()->json(['error' => 'Invalid request data.'], 422);
        }

        try {
            $chunkedArray = array_chunk($commentsData, 100);
            foreach ($chunkedArray as $index => $chunk) {
                set_time_limit(0);

                $userCount = Concurrency::run(function () use ($chunk) {
                    Category::insert($chunk);
                });
            }
            return response()->json(['success' => true], 200);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}
