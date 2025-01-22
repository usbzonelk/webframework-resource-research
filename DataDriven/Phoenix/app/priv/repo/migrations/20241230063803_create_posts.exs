defmodule App.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :text
      add :slug, :string
      add :content, :text
      add :postStatus, :string
      add :lastUpdated, :naive_datetime
    end

    create unique_index(:posts, :slug)
  end
end
