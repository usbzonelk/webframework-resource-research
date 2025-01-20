<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Log\Logger;
use Illuminate\Support\Facades\Concurrency;

class ConcurrentController extends Controller
{
    public function readFile(Request $request)
    {
        try {
            $filePath = storage_path('app/textFile.txt');
            if (!file_exists($filePath)) {
                return response()->json(['error' => 'File does not exist'], 404);
            }
            try {
                $fileContent = Concurrency::run(function () use ($filePath) {
                    $_filecontent =  file_get_contents($filePath);
                    sleep(2);
                    return $_filecontent;
                });
                return response()->json(['success' => true, 'message' => $fileContent]);
            } catch (\Exception $e) {
                return response()->json(['success' => false, 'message' => 'Error reading file: ' . $e->getMessage()], 500);
            }
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}
