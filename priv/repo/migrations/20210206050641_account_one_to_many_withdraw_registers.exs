defmodule StoneAccountApi.Repo.Migrations.AccountOneToManyWithdrawRegisters do
  use Ecto.Migration

  def change do
    alter table(:withdraw_registers) do
      add :account_id, references(:accounts, type: :uuid)
    end
  end
end
