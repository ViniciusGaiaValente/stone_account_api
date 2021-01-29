defmodule StoneAccountApi.Banking do
  @moduledoc """
  The Banking context.
  """
  alias StoneAccountApi.Repo

  alias StoneAccountApi.Banking.Account

  @doc """
  Gets a single account and the holder associated to it.
  Remove the field ':password_hash' and the virtual field ':password' before returns the result

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id) do
    Repo.get(Account, id)
    |> Repo.preload(:holder)
    |> Map.delete(:password)
    |> Map.delete(:password_hash)
  end

  @doc """
  Creates a account, returns it self and the holder associated to it.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    attrs =
      attrs
      |> Map.put("balance", 1000)

    result =
      %Account{}
      |> Account.changeset(attrs)
      |> Repo.insert()

    case result do
      { :ok, account } -> { :ok, Repo.preload(account, :holder) }
      { :error, error } -> { :error, error }
    end
  end
end
