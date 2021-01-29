defmodule StoneAccountApi.Repo.Migrations.CreateHolders do
  use Ecto.Migration

  def change do
    create table(:holders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :email, :string
      add :birthdate, :naive_datetime

      timestamps()
    end

    create unique_index(:holders, [:email])

  end
end
