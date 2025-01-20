<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Post;
use App\Models\Comment;
use App\Models\Author;
use App\Models\Category;
use Illuminate\Support\Facades\Concurrency;
use Symfony\Component\Console\Output\ConsoleOutput;

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

        // Get input data (make sure it's an array)
        $commentsData = $request->input('cats', []);
        if (!is_array($commentsData) || count($commentsData) < 1) {
            return response()->json(['error' => 'Invalid request data.'], 422);
        }

        try {
            // Split the array into two halves
            $halfwayPoint = ceil(count($commentsData) / 2);
            $firstHalf = array_slice($commentsData, 0, $halfwayPoint);
            $secondHalf = array_slice($commentsData, $halfwayPoint);

            // Run first half concurrently
            Concurrency::run(array_map(function ($postData) {
                return function () use ($postData) {
                    // Check if post with the same slug exists, if so, skip
                    if (Post::where('slug', $postData['slug'])->exists()) {
                        return; // Skip this post
                    }

                    // Create the post
                    $post = Post::create($postData);

                    // Output and log the post data
                    $output = new ConsoleOutput();
                    $output->writeln($post);

                    // Log post data
                    log($postData);

                    // Handle authors if present
                    if (isset($postData['authors'])) {
                        $authorEmails = array_column($postData['authors'], 'email');
                        $authorIds = Author::whereIn('email', $authorEmails)->pluck('id')->toArray();
                        $post->authors()->sync($authorIds);
                    }

                    // Handle categories if present
                    if (isset($postData['categories'])) {
                        $categoryNames = array_column($postData['categories'], 'name');
                        $categoryIds = Category::whereIn('name', $categoryNames)->pluck('id')->toArray();
                        $post->categories()->sync($categoryIds);
                    }
                };
            }, $firstHalf)); // Execute concurrently for the first half

            // After the first half finishes, run the second half concurrently
            Concurrency::run(array_map(function ($postData) {
                return function () use ($postData) {
                    // Same logic for the second half of posts
                    if (Post::where('slug', $postData['slug'])->exists()) {
                        return; // Skip this post
                    }

                    $post = Post::create($postData);
                    $output = new ConsoleOutput();
                    $output->writeln($post);
                    log($postData);

                    if (isset($postData['authors'])) {
                        $authorEmails = array_column($postData['authors'], 'email');
                        $authorIds = Author::whereIn('email', $authorEmails)->pluck('id')->toArray();
                        $post->authors()->sync($authorIds);
                    }

                    if (isset($postData['categories'])) {
                        $categoryNames = array_column($postData['categories'], 'name');
                        $categoryIds = Category::whereIn('name', $categoryNames)->pluck('id')->toArray();
                        $post->categories()->sync($categoryIds);
                    }
                };
            }, $secondHalf)); // Execute concurrently for the second half

            return response()->json(['success' => true], 200);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}
