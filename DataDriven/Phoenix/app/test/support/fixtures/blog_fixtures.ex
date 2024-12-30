defmodule App.BlogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Blog` context.
  """

  @doc """
  Generate a author.
  """
  def author_fixture(attrs \\ %{}) do
    {:ok, author} =
      attrs
      |> Enum.into(%{
        email: "some email",
        id: 42,
        name: "some name"
      })
      |> App.Blog.create_author()

    author
  end

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        id: 42,
        name: "some name"
      })
      |> App.Blog.create_category()

    category
  end

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        content: "some content",
        id: 42,
        last_updated: ~N[2024-12-29 06:38:00],
        post_status: "some post_status",
        slug: "some slug",
        title: "some title"
      })
      |> App.Blog.create_post()

    post
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        author_name: "some author_name",
        content: "some content",
        last_updated: ~N[2024-12-29 06:39:00],
        post_id: 42
      })
      |> App.Blog.create_comment()

    comment
  end
end
