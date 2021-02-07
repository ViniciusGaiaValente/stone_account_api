defmodule StoneAccountApi.Backoffice do
  @moduledoc """
  The Backoffice context.
  """

  import Ecto.Query, warn: false
  alias StoneAccountApi.Repo

  alias StoneAccountApi.Backoffice.WithdrawRegister

  @doc """
  Returns the list of withdraw_registers.

  ## Examples

      iex> list_withdraw_registers()
      [%WithdrawRegister{}, ...]

  """
  def list_withdraw_registers do
    Repo.all(WithdrawRegister)
  end

  @doc """
  Creates a withdraw_register.

  ## Examples

      iex> create_withdraw_register(%{field: value})
      {:ok, %WithdrawRegister{}}

      iex> create_withdraw_register(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_withdraw_register(attrs \\ %{}) do
    %WithdrawRegister{}
    |> WithdrawRegister.changeset(attrs)
    |> Repo.insert()
  end

  alias StoneAccountApi.Backoffice.TransferenceRegister

  @doc """
  Returns the list of transference_registers.

  ## Examples

      iex> list_transference_registers()
      [%TransferenceRegister{}, ...]

  """
  def list_transference_registers do
    Repo.all(TransferenceRegister)
  end

  @doc """
  Creates a transference_register.

  ## Examples

      iex> create_transference_register(%{field: value})
      {:ok, %TransferenceRegister{}}

      iex> create_transference_register(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transference_register(attrs \\ %{}) do
    %TransferenceRegister{}
    |> TransferenceRegister.changeset(attrs)
    |> Repo.insert()
  end
end
