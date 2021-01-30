defmodule StoneAccountApi.Banking.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :number, :integer, read_after_writes: true
    field :balance, Money.Ecto.Amount.Type
    field :password_hash, :string
    field :password, :string, virtual: true

    has_one :holder, StoneAccountApi.Banking.Holder
    timestamps()
  end

  def changeset(account, attrs) do
    account
    |> cast(attrs, [:balance, :password])
    |> validate_required([:balance, :password])
    |> cast_assoc(:holder)
    |> put_pass_hash()
  end

  defp put_pass_hash(
    %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
  ) do
    change(changeset, Bcrypt.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset
end
