defmodule StoneAccountApiWeb.TransferenceRegisterController do
  use StoneAccountApiWeb, :controller

  alias StoneAccountApi.Backoffice

  action_fallback StoneAccountApiWeb.FallbackController

  def index(conn, _params) do
    transference_registers = Backoffice.list_transference_registers()
    render(conn, "index.json", transference_registers: transference_registers)
  end
end
