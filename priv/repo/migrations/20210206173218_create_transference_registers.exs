defmodule StoneAccountApi.Repo.Migrations.CreateTransferenceRegisters do
  use Ecto.Migration

  def change do
    create table(:transference_registers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :origin_old_balance, :integer
      add :origin_new_balance, :integer
      add :destination_old_balance, :integer
      add :destination_new_balance, :integer
      add :value, :integer

      timestamps()
    end

  end
end
