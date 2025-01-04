defmodule AppWeb.PostController do
  use AppWeb, :controller
  import Ecto.Query
  alias App.{Repo}
  alias App.Blog.{Post, Comment, Author}

  def create(conn, %{"postData" => post_data}) do
    last_updated_str = Map.get(post_data, "lastUpdated", "")

    last_updated =
      if last_updated_str != "" do
        case NaiveDateTime.from_iso8601("#{last_updated_str} 00:00:00") do
          {:ok, naive_datetime} -> naive_datetime
          _error -> nil
        end
      else
        nil
      end

    post_data = Map.put(post_data, "lastUpdated", last_updated)

    changeset = Post.changeset(%Post{}, post_data)

    authors_ids = Map.get(post_data, "authors", [])

    authors =
      Author
      |> where([a], a.id in ^authors_ids)
      |> Repo.all()

    changeset =
      changeset
      |> Ecto.Changeset.put_assoc(:authors, authors)

    case Repo.insert(changeset) do
      {:ok, _post} ->
        json(conn, %{success: true})

      {:error, changeset} ->
        error_message = "Error creating database entry: #{inspect(changeset)}"
        json(conn, %{error: error_message})
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

  def bulk_status_update(conn, %{"postIDs" => post_ids, "newStatus" => new_status}) do
    if is_nil(new_status) or not is_list(post_ids) or length(post_ids) < 1 do
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{error: "Invalid request data."})
    else
      {count, _} =
        from(p in Post, where: p.id in ^post_ids)
        |> Repo.update_all(set: [postStatus: new_status])

      if count > 0 do
        json(conn, %{success: true})
      else
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Error updating database entry!"})
      end
    end
  end

  def edit(conn, %{"postData" => post_data}) do
    id = post_data["id"]

    if is_nil(id) or map_size(post_data) < 1 do
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{error: "Invalid request."})
    else
      post = Repo.get!(Post, id)
      changeset = Post.changeset(post, post_data)

      authors_ids = Map.get(post_data, "authors", [])

      if length(authors_ids) > 0 do
        authors =
          Author
          |> where([a], a.id in ^authors_ids)
          |> Repo.all()

        changeset =
          changeset
          |> Ecto.Changeset.put_assoc(:authors, authors)
      end

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
        from(p in Post,
          where: ilike(p.title, ^"%#{search}%") or ilike(p.content, ^"%#{search}%"),
          preload: [:authors]
        )
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
      from(p in Post, order_by: [desc: p.lastUpdated], preload: [:authors])
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
        join: p in Post,
        on: c.post_id == p.id,
        group_by: p.id,
        select: %{post: p.id, count: count(c.id)},
        order_by: [desc: count(c.id)],
        limit: 10
      )
      |> Repo.all()

    post_ids = Enum.map(max_posts, & &1.post)

    posts =
      from(p in Post,
        where: p.id in ^post_ids,
        order_by: fragment("array_position(?, ?)", ^post_ids, p.id)
      )
      |> Repo.all()
      |> Repo.preload([:authors, :categories])

    if length(posts) < 1 do
      json(conn, %{result: "No posts found."})
    else
      json(conn, %{result: posts})
    end
  end
end
