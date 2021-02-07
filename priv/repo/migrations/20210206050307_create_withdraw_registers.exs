defmodule StoneAccountApi.Repo.Migrations.CreateWithdrawRegisters do
  use Ecto.Migration

  def change do
    create table(:withdraw_registers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :old_balance, :integer
      add :new_balance, :integer
      add :value, :integer

      timestamps()
    end

  end
end
