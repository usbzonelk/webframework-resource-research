defmodule App.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :slug, :string
      add :content, :string
      add :postStatus, :string
      add :lastUpdated, :naive_datetime
    end
  end
end
