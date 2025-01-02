defmodule App.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :name, :string
      add :email, :string
    end

    create unique_index(:authors, :email)
  end
end
