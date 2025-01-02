defmodule App.Blog.PostAuthors do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.Blog.{Post, Author}

  schema "post_authors" do
    belongs_to :post, Post
    belongs_to :author, Author
  end
end
