defmodule StoneAccountApiWeb.WithdrawRegisterController do
  use StoneAccountApiWeb, :controller

  alias StoneAccountApi.Backoffice

  action_fallback StoneAccountApiWeb.FallbackController

  def index(conn, _params) do
    withdraw_registers = Backoffice.list_withdraw_registers()
    render(conn, "index.json", withdraw_registers: withdraw_registers)
  end
end
