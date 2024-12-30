defmodule App.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :author_name, :string
      add :content, :string
      add :post, :integer
      add :last_updated, :naive_datetime
    end
  end
end
