defmodule AppWeb.PostController do
  use AppWeb, :controller
  import Ecto.Query
  alias App.{Repo}
  alias App.Blog.{Post, Comment}

  def create(conn, %{"post_data" => post_data}) do
    changeset = Post.changeset(%Post{}, post_data)

    case Repo.insert(changeset) do
      {:ok, _post} ->
        json(conn, %{success: true})

      {:error, _changeset} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Error creating database entry!"})
    end
  end

  def get(conn, %{"page" => page, "size" => size}) do
    page = String.to_integer(page || "1")
    size = String.to_integer(size || "10")

    query =
      from p in Post,
        preload: [:authors]

    posts = Repo.paginate(query, page: page, page_size: size)

    if length(posts.entries) < 1 do
      json(conn, %{result: "No posts found."})
    else
      json(conn, %{result: posts.entries})
    end
  end

  def bulk_status_update(conn, %{"post_ids" => post_ids, "new_status" => new_status}) do
    if is_nil(new_status) or not is_list(post_ids) or length(post_ids) < 1 do
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{error: "Invalid request data."})
    else
      {count, _} =
        from(p in Post, where: p.id in ^post_ids)
        |> Repo.update_all(set: [post_status: new_status])

      if count > 0 do
        json(conn, %{success: true})
      else
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Error updating database entry!"})
      end
    end
  end

  def edit(conn, %{"post_data" => post_data}) do
    id = post_data["id"]

    if is_nil(id) or map_size(post_data) < 1 do
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{error: "Invalid request."})
    else
      post = Repo.get!(Post, id)
      changeset = Post.changeset(post, post_data)

      case Repo.update(changeset) do
        {:ok, _post} ->
          json(conn, %{success: true})

        {:error, _changeset} ->
          conn
          |> put_status(:internal_server_error)
          |> json(%{error: "Error updating database entry!"})
      end
    end
  end

  def search(conn, %{"search" => search}) do
    if is_nil(search) do
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{error: "Invalid request data."})
    else
      posts =
        from(p in Post, where: ilike(p.title, ^"%#{search}%") or ilike(p.content, ^"%#{search}%"))
        |> Repo.all()

      if length(posts) < 1 do
        json(conn, %{result: "No posts found."})
      else
        json(conn, %{result: posts})
      end
    end
  end

  def sort_by_date(conn, _params) do
    posts =
      from(p in Post, order_by: [desc: p.last_updated])
      |> Repo.all()

    if length(posts) < 1 do
      json(conn, %{result: "No posts found."})
    else
      json(conn, %{result: posts})
    end
  end

  def popular_posts(conn, _params) do
    max_posts =
      from(c in Comment,
        group_by: c.post_id,
        select: %{post_id: c.post_id, count: count(c.id)},
        order_by: [desc: count(c.id)],
        limit: 10
      )
      |> Repo.all()

    post_ids = Enum.map(max_posts, & &1.post_id)

    posts =
      from(p in Post, where: p.id in ^post_ids)
      |> Repo.all()
      |> Repo.preload([:authors, :categories])

    if length(posts) < 1 do
      json(conn, %{result: "No posts found."})
    else
      json(conn, %{result: posts})
    end
  end
end
