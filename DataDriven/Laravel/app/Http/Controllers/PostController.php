<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Post;
use App\Models\Comment;
use Illuminate\Support\Facades\Concurrency;

class PostController extends Controller
{
    public function create(Request $request)
    {
        $postData = $request->input('postData');
        try {
            $post = Post::create($postData);
            if ($post) {
                return response()->json(['success' => true], 200);
            } else {
                throw new \Exception('Error creating database entry!');
            }
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function get(Request $request)
    {
        $page = $request->query('page', 1);
        $size = $request->query('size', 10);
        try {
            $posts = Post::with(['authors', 'categories'])
                ->skip($size * ($page - 1))
                ->take($size)
                ->get();
            if ($posts->isEmpty()) {
                return response()->json(['result' => 'No posts found.'], 200);
            } else {
                return response()->json(['result' => $posts], 200);
            }
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function bulkStatusUpdate(Request $request)
    {
        $postIDs = $request->input('postIDs');
        $newStatus = $request->input('newStatus');
        if (!$newStatus || !is_array($postIDs) || count($postIDs) < 1) {
            return response()->json(['error' => 'Invalid request data.'], 422);
        }
        try {
            $updated = Post::whereIn('id', $postIDs)->update(['postStatus' => $newStatus]);
            if ($updated) {
                return response()->json(['success' => true], 200);
            } else {
                throw new \Exception('Error updating database entry!');
            }
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function edit(Request $request)
    {
        $postData = $request->input('postData');
        if (empty($postData) || !isset($postData['id'])) {
            return response()->json(['error' => 'Invalid request.'], 422);
        }
        try {
            $post = Post::find($postData['id']);
            if ($post) {
                $post->update($postData);
                return response()->json(['success' => true], 200);
            } else {
                throw new \Exception('Error updating database entry!');
            }
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function search(Request $request)
    {
        $search = $request->query('search');
        if (!$search) {
            return response()->json(['error' => 'Invalid request data.'], 422);
        }
        try {
            $posts = Post::where('title', 'like', "%{$search}%")
                ->orWhere('content', 'like', "%{$search}%")
                ->get();
            if ($posts->isEmpty()) {
                return response()->json(['result' => 'No posts found.'], 200);
            } else {
                return response()->json(['result' => $posts], 200);
            }
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function sortByDate()
    {
        try {
            $posts = Post::orderBy('lastUpdated', 'desc')->get();
            if ($posts->isEmpty()) {
                return response()->json(['result' => 'No posts found.'], 200);
            } else {
                return response()->json(['result' => $posts], 200);
            }
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function popularPosts()
    {
        try {
            $maxPosts = Comment::selectRaw('post, COUNT(*) as count')
                ->groupBy('post')
                ->orderBy('count', 'desc')
                ->limit(10)
                ->pluck('post');
            if ($maxPosts->isEmpty()) {
                return response()->json(['result' => 'No posts found.'], 200);
            } else {
                $posts = Post::whereIn('id', $maxPosts)
                    ->with(['authors', 'categories'])
                    ->get();
                return response()->json(['result' => $posts], 200);
            }
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function newPosts(Request $request)
    {
        set_time_limit(0);
        $commentsData = $request->input('cats', []);
        if (!is_array($commentsData) || count($commentsData) < 1) {
            return response()->json(['error' => 'Invalid request data.'], 422);
        }

        try {
            $chunkedArray = array_chunk($commentsData, 100);
            foreach ($chunkedArray as $index => $chunk) {
                $userCount = Concurrency::run(function () use ($chunk) {
                    set_time_limit(0);

                    foreach ($chunk as $postData) {
                        $post = Post::create($postData);

                        if (isset($postData['authors'])) {
                            $post->authors()->sync($postData['authors']);
                        }

                        if (isset($postData['categories'])) {
                            $post->categories()->sync($postData['categories']);
                        }
                    }
                });
            }
            return response()->json(['success' => true], 200);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}
