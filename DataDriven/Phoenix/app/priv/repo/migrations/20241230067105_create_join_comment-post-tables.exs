defmodule App.Repo.Migrations.CreatePostCategories do
  use Ecto.Migration

  def change do
    create table(:post_categories) do
      add :post_id, references(:posts, on_delete: :delete_all)
      add :category_id, references(:categories, on_delete: :delete_all)
    end

    # Ensure each post-category pair is unique
    create unique_index(:post_categories, [:post_id, :category_id])
  end
end
