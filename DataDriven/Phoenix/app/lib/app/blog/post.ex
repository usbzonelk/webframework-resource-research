defmodule App.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :slug, :string
    field :content, :string
    field :postStatus, :string
    field :lastUpdated, :naive_datetime
    many_to_many :authors, App.Blog.Author, join_through: "post_authors"
    many_to_many :categories, App.Blog.Author, join_through: "post_categories"
    has_many :comments, App.Blog.Comment
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :slug, :id, :content, :postStatus, :lastUpdated])
    |> validate_required([:title, :slug, :id, :content, :postStatus, :lastUpdated])
  end
end
