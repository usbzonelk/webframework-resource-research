defmodule App.Blog.PostCategories do
  use Ecto.Schema
  import Ecto.Changeset
  alias App.Blog.{Post, Category}

  schema "post_categories" do
    belongs_to :post, Post
    belongs_to :category, Category
  end
end
