defmodule StoneAccountApi.Backoffice.WithdrawRegister do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "withdraw_registers" do
    field :new_balance, Money.Ecto.Amount.Type
    field :old_balance, Money.Ecto.Amount.Type
    field :value, Money.Ecto.Amount.Type

    belongs_to :account, StoneAccountApi.Banking.Account
    timestamps()
  end

  @doc false
  def changeset(withdraw_register, attrs) do
    withdraw_register
    |> cast(attrs, [:old_balance, :new_balance, :value, :account_id])
    |> validate_required([:old_balance, :new_balance, :value, :account_id])
  end
end
