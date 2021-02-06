defmodule StoneAccountApiWeb.WithdrawController do

  use StoneAccountApiWeb, :controller

  alias StoneAccountApi.Withdraw

  def withdraw(conn, %{ "origin" => origin, "value" => value } = _params) do
    case Withdraw.withdraw(conn.assigns.signed_account.number, origin, value) do
      { :ok, result, status } ->
        conn
        |> put_status(status)
        |> json(%{
          result: %{
            origin: result.origin,
            value: result.value,
            balance: %{
              precise: result.balance.amount,
              decimal: Money.to_decimal(result.balance),
              display: Money.to_string(result.balance)
            }
          }
        })
      { :error, errors, status } ->
        conn
        |> put_status(status)
        |> json(%{ errors: errors })
        |> halt()
    end
  end
end
