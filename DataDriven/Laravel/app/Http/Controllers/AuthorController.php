<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Author;
use App\Models\Post;
use Illuminate\Support\Facades\Concurrency;

class AuthorController extends Controller
{
    public function getPosts(Request $request)
    {
        try {
            $emails = $request->input('emails');
            $authors = Author::whereIn('email', $emails)->get();

            if ($authors->isEmpty()) {
                return response()->json(['result' => 'No authors found.'], 200);
            }

            $authorIDs = $authors->pluck('id');
            $postsByAuthor = Post::whereIn('id', function ($query) use ($authorIDs) {
                $query->select('post')
                    ->from('author_post')
                    ->whereIn('author', $authorIDs);
            })->get();

            if ($postsByAuthor->isEmpty()) {
                return response()->json(['result' => 'No posts found.'], 200);
            } else {
                return response()->json(['result' => $postsByAuthor], 200);
            }
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
    public function newAuth(Request $request)
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
                    Author::insert($chunk);
                });
            }
            return response()->json(['success' => true], 200);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}
