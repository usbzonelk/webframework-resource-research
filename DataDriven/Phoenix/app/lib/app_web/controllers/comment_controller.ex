defmodule AppWeb.CommentController do
  use AppWeb, :controller

  use Phoenix.Controller,
    formats: [:json]

  alias App.Repo
  alias App.Blog.Comment
  alias App.Blog.Post
  import Ecto.Query, only: [from: 2]

  def create_bulk(conn, %{"commentsData" => comments_data}) do
    if !is_list(comments_data) or length(comments_data) < 1 do
      json(conn, %{error: "Invalid request data."})
    else
      transformed_data =
        Enum.map(comments_data, fn %{
                                     "authorName" => author_name,
                                     "content" => content,
                                     "post" => post_id,
                                     "lastUpdated" => last_updated
                                   } ->
          naive_datetime =
            case NaiveDateTime.from_iso8601("#{last_updated}T00:00:00") do
              {:ok, dt} -> dt
              {:error, _} -> raise ArgumentError, "Invalid datetime format: #{last_updated}"
            end

          %{
            authorName: author_name,
            content: content,
            lastUpdated: naive_datetime,
            post_id: post_id
          }
        end)

      case Repo.insert_all(Comment, transformed_data) do
        {count, _} when count > 0 ->
          json(conn, %{success: true})

        _ ->
          json(conn, %{error: "Error creating database entry!"})
      end
    end
  rescue
    e -> json(conn, %{error: "#{e}"})
  end

  def delete_bulk(conn, %{"postIDs" => post_ids}) do
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
