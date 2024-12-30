defmodule App.Blog.Author do
  use Ecto.Schema
  import Ecto.Changeset

  schema "authors" do
    field :name, :string
    field :email, :string
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:name, :email, :id])
    |> validate_required([:name, :email, :id])
  end
end
