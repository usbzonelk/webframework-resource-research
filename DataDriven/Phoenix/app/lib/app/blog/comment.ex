defmodule App.Blog.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :authorName, :string
    field :content, :string
    belongs_to :post, App.Blog.Post
    field :lastUpdated, :naive_datetime
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:author_name, :content, :post, :lastUpdated])
    |> validate_required([:author_name, :content, :post, :lastUpdated])
  end
end
