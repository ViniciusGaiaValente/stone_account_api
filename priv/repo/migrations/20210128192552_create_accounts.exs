defmodule StoneAccountApi.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :number, :bigserial, null: false
      add :balance, :integer
      add :password_hash, :string

      timestamps()
    end

  end
end
