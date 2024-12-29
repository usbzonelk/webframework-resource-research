<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Comment;
use App\Models\Post;

class CommentController extends Controller
{
    public function createBulk(Request $request)
    {
        $commentsData = $request->input('commentsData', []);
        if (!is_array($commentsData) || count($commentsData) < 1) {
            return response()->json(['error' => 'Invalid request data.'], 422);
        }

        try {
            $commentsCreation = Comment::insert($commentsData);
            if ($commentsCreation) {
                return response()->json(['success' => true], 200);
            } else {
                throw new \Exception('Error creating database entry!');
            }
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function deleteBulk(Request $request)
    {
        $postIDs = $request->input('postIDs', []);
        if (!is_array($postIDs) || count($postIDs) < 1) {
            return response()->json(['error' => 'Invalid request data.'], 422);
        }

        try {
            $posts = Post::whereIn('id', $postIDs)->get();
            if ($posts->isEmpty()) {
                return response()->json(['result' => 'No posts found.'], 200);
            }

            $postIDs = $posts->pluck('id')->toArray();
            $deleted = Comment::whereIn('post', $postIDs)->delete();
            if ($deleted) {
                return response()->json(['success' => true], 200);
            } else {
                throw new \Exception('Error deleting database entry!');
            }
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}
