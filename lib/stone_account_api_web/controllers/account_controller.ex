defmodule StoneAccountApiWeb.AccountController do
  use StoneAccountApiWeb, :controller

  alias StoneAccountApi.Banking
  alias StoneAccountApi.Banking.Account
  alias StoneAccountApi.Auth.Guardian

  action_fallback StoneAccountApiWeb.FallbackController

  def create(conn, %{"account" => account_params}) do
    with { :ok, %Account{} = account } <- Banking.create_account(account_params),
      { :ok, token, _claims } <- Guardian.encode_and_sign(account.id) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.account_path(conn, :show, account))
      |> render("create_account_response.json", account: account, token: token)
    end
  end

  def signin(conn, _params) do
    case Plug.BasicAuth.parse_basic_auth(conn) do
      :error ->
        conn
        |> put_status(:bad_request)
        |> json(%{ error: "In order to signin you need to provide a valid account number and password" })
        |> halt()
      { number, password } ->
        case Guardian.authenticate(number, password) do
          { :error, reason } ->
            conn
            |> put_status(:unauthorized)
            |> json(%{ error: reason })
            |> halt()
          { :ok, token } ->
            conn
            |> put_status(:ok)
            |> json(%{ token: token })
        end
    end
  end

  def show(conn, %{ "number" => number }) do
    if number == to_string(conn.assigns.signed_account.number) do
      conn
      |> put_status(:ok)
      |> render("account.json", account: conn.assigns.signed_account)
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{ error: "Only the account holder can access this information" })
      |> halt()
    end
  end
end
