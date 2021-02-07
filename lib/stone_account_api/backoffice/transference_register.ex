defmodule StoneAccountApi.Backoffice.TransferenceRegister do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transference_registers" do
    field :destination_new_balance, Money.Ecto.Amount.Type
    field :destination_old_balance, Money.Ecto.Amount.Type
    field :origin_new_balance, Money.Ecto.Amount.Type
    field :origin_old_balance, Money.Ecto.Amount.Type
    field :value, Money.Ecto.Amount.Type

    belongs_to :origin, StoneAccountApi.Banking.Account
    belongs_to :destination, StoneAccountApi.Banking.Account
    timestamps()
  end

  @doc false
  def changeset(transference_register, attrs) do
    transference_register
    |> cast(attrs, [:origin_old_balance, :origin_new_balance, :destination_old_balance, :destination_new_balance, :value, :origin_id, :destination_id])
    |> validate_required([:origin_old_balance, :origin_new_balance, :destination_old_balance, :destination_new_balance, :value, :origin_id, :destination_id])
  end
end
