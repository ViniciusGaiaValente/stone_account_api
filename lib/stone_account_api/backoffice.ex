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

  @doc """
  Returns the sum of today's transaction's values.

  ## Examples

      iex> todays_report()
      R$1.000,00

  """
  def todays_report() do #TODO REFACTOR, THIS OPERATION IS VERY EXPENSIVE AND SHOULD BE OPTIMIZED
    now = Timex.now()

    withdraw_registers = Repo.all(
      from w in WithdrawRegister,
      where: w.inserted_at >= ^Timex.beginning_of_day(now),
      where: w.inserted_at <= ^Timex.end_of_day(now)
    )

    transference_registers = Repo.all(
      from w in TransferenceRegister,
      where: w.inserted_at >= ^Timex.beginning_of_day(now),
      where: w.inserted_at <= ^Timex.end_of_day(now)
    )

    calculate_total_value(withdraw_registers, transference_registers)
  end

  @doc """
  Returns the sum of this month's transaction's values.

  ## Examples

      iex> this_month_report()
      R$1.000,00

  """
  def this_month_report() do #TODO REFACTOR, THIS OPERATION IS VERY EXPENSIVE AND SHOULD BE OPTIMIZED
    now = Timex.now()

    withdraw_registers = Repo.all(
      from w in WithdrawRegister,
      where: w.inserted_at >= ^Timex.beginning_of_month(now),
      where: w.inserted_at <= ^Timex.end_of_month(now)
    )

    transference_registers = Repo.all(
      from w in TransferenceRegister,
      where: w.inserted_at >= ^Timex.beginning_of_month(now),
      where: w.inserted_at <= ^Timex.end_of_month(now)
    )

    calculate_total_value(withdraw_registers, transference_registers)
  end

  @doc """
  Returns the sum of this year's transaction's values.

  ## Examples

      iex> this_year_report()
      R$1.000,00

  """
  def this_year_report() do #TODO REFACTOR, THIS OPERATION IS VERY EXPENSIVE AND SHOULD BE OPTIMIZED
    now = Timex.now()

    withdraw_registers = Repo.all(
      from w in WithdrawRegister,
      where: w.inserted_at >= ^Timex.beginning_of_year(now),
      where: w.inserted_at <= ^Timex.end_of_year(now)
    )

    transference_registers = Repo.all(
      from w in TransferenceRegister,
      where: w.inserted_at >= ^Timex.beginning_of_year(now),
      where: w.inserted_at <= ^Timex.end_of_year(now)
    )

    calculate_total_value(withdraw_registers, transference_registers)
  end

  defp calculate_total_value(withdraw_registers, transference_registers) do
    withdraw_registers
    |> Enum.concat(transference_registers)
    |> Enum.reduce(
      Money.new(0),
      fn x, acc ->
        Money.add(x.value, acc)
      end)
    |> Money.to_string()
  end
end
