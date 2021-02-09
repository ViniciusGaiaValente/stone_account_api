defmodule StoneAccountApiWeb.BackofficeAuthPlug do
  use StoneAccountApiWeb, :controller

  def init(_params) do

  end

  def call(conn, _params) do

    case Plug.BasicAuth.parse_basic_auth(conn) do
      { "admin", "1234" } ->
        conn
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Wrong username or password."})
        |> halt()
    end
  end
end
