defmodule AppWeb.AuthorController do
  use AppWeb, :controller

  alias App.Repo
  alias App.Blog.Author
  alias App.Blog.Post
  import Ecto.Query, only: [from: 2]

  def get_posts(conn, %{"emails" => emails}) do
    if !is_list(emails) or length(emails) < 1 do
      json(conn, %{error: "Invalid request data."})
      |> halt()
    end

    authors = Repo.all(from a in Author, where: a.email in ^emails)

    if length(authors) < 1 do
      json(conn, %{result: "No authors found."})
    else
      author_ids = Enum.map(authors, & &1.id)

      posts_by_author =
        Repo.all(
          from p in Post,
            join: pa in "post_authors",
            on: pa.post_id == p.id,
            where: pa.author_id in ^author_ids,
            select: %{post: p}
        )

      if length(posts_by_author) < 1 do
        json(conn, %{result: "No posts found."})
      else
        json(conn, %{result: posts_by_author})
      end
    end
  rescue
    e ->
      json(conn, %{error: "#{e}"})
      IO.inspect(e, label: "Error")
  end
end
