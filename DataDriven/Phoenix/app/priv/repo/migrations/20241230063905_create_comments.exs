defmodule App.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :author_name, :string
      add :content, :string
      add :post_id, references(:posts, on_delete: :delete_all)
      add :last_updated, :naive_datetime
    end
  end
end
