defmodule App.Blog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :id])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
