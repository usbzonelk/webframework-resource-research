defmodule AppWeb.CommentController do
  use AppWeb, :controller

  use Phoenix.Controller,
    formats: [:json]

  alias App.Repo
  alias App.Blog.Comment
  alias App.Blog.Post
  import Ecto.Query, only: [from: 2]

  def create_bulk(conn, %{"comments_data" => comments_data}) do
    IO.inspect("huhuuu")
    if !is_list(comments_data) or length(comments_data) < 1 do
      json(conn, %{error: "Invalid request data."})

    else
      case Repo.insert_all(Comment, comments_data) do
        {count, _} when count > 0 ->
          json(conn, %{success: true})

        _ ->
          json(conn, %{error: "Error creating database entry!"})
      end
    end
  rescue
    e -> json(conn, %{error: "#{e}"})
  end

  def delete_bulk(conn, %{"post_ids" => post_ids}) do
    if !is_list(post_ids) or length(post_ids) < 1 do
      json(conn, %{error: "Invalid request data."})
    else
      posts = Repo.all(from p in Post, where: p.id in ^post_ids)

      if length(posts) < 1 do
        json(conn, %{result: "No posts found."})
      else
        post_ids = Enum.map(posts, & &1.id)
        {deleted_count, _} = Repo.delete_all(from c in Comment, where: c.post_id in ^post_ids)

        if deleted_count > 0 do
          json(conn, %{success: true})
        else
          json(conn, %{error: "Error deleting database entry!"})
        end
      end
    end
  rescue
    e -> json(conn, %{error: "#{e}"})
  end
end
