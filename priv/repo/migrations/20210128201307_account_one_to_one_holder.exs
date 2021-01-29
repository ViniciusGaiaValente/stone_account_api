defmodule StoneAccountApi.Repo.Migrations.AccountOneToOneHolder do
  use Ecto.Migration

  def change do
    alter table(:holders) do
      add :account_id, references(:accounts, type: :uuid)
    end
  end
end
