defmodule StoneAccountApi.Banking.Holder do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "holders" do
    field :birthdate, :naive_datetime
    field :email, :string
    field :name, :string

    belongs_to :account, StoneAccountApi.Banking.Account
    timestamps()
  end

  @doc false
  def changeset(holder, attrs) do
    holder
    |> cast(attrs, [:name, :email, :birthdate])
    |> validate_required([:name, :email, :birthdate])
    |> unique_constraint(:email, message: "There is already a holder with this email")
  end
end
