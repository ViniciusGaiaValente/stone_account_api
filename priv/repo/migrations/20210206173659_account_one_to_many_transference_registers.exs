defmodule StoneAccountApi.Repo.Migrations.AccountOneToManyTransferenceRegisters do
  use Ecto.Migration

  def change do
    alter table(:transference_registers) do
      add :origin_id, references(:accounts, type: :uuid)
      add :destination_id, references(:accounts, type: :uuid)
    end
  end
end
