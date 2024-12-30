defmodule App.Repo.Migrations.CreatePostAuthors do
  use Ecto.Migration

  def change do
    create table(:post_authors) do
      add :post_id, references(:posts, on_delete: :delete_all)
      add :author_id, references(:authors, on_delete: :delete_all)
    end

    # Ensure each post-author pair is unique
    create unique_index(:post_authors, [:post_id, :author_id])
  end
end
