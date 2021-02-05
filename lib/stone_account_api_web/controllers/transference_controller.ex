defmodule StoneAccountApiWeb.TransferenceController do
  use StoneAccountApiWeb, :controller

  alias StoneAccountApi.Transference

  def transfer(conn, %{ "origin" => origin, "destination" => destination, "value" => value } = _params) do
    case Transference.tranfer(conn.assigns.signed_account.number, origin, destination, value) do
      { :ok, result, status } ->
        conn
        |> put_status(status)
        |> json(%{
          result: %{
            origin: result.origin,
            destination: result.destination,
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
