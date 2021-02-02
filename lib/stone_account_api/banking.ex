defmodule StoneAccountApi.Banking do
  @moduledoc """
  The Banking context.
  """
  alias StoneAccountApi.Repo

  alias StoneAccountApi.Banking.Account

  @doc """
  Gets the account with the given id and the holder associated to it.
  Remove the field ':password_hash' and the virtual field ':password' before returns the result

  Return nil if the Account does not exist.

  ## Examples

      iex> get_account_by_id(123)
      %Account{}

      iex> get_account_by_id(456)
      nil

  """
  def get_account_by_id(id) do
    case Repo.get(Account, id) do
      nil -> nil
      account ->
        account
        |> Repo.preload(:holder)
        |> Map.delete(:password)
        |> Map.delete(:password_hash)
    end
  end

  @doc """
  Gets the account with the given number and the holder associated to it.

  Return nil if the Account does not exist.

  ## Examples

      iex> get_account_by_number(1)
      %Account{}

      iex> get_account_by_number(2)
      nil
  """
  def get_account_by_number(number) do
    case Repo.get_by(Account, number: number) do
    nil -> nil
    account ->
      account
      |> Repo.preload(:holder)
    end
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
      |> Map.put("balance", Money.new(100000, :BRL))

    result =
      %Account{}
      |> Account.changeset(attrs)
      |> Repo.insert()

    case result do
      { :ok, account } ->
        {
          :ok,
          Repo.preload(account, :holder)
          |> Map.delete(:password)
          |> Map.delete(:password_hash)
        }
      { :error, error } -> { :error, error }
    end
  end
end
