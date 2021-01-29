defmodule StoneAccountApiWeb.AccountController do
  use StoneAccountApiWeb, :controller

  alias StoneAccountApi.Banking
  alias StoneAccountApi.Banking.Account

  action_fallback StoneAccountApiWeb.FallbackController

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Banking.create_account(account_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.account_path(conn, :show, account))
      |> render("show.json", account: account)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Banking.get_account!(id)
    render(conn, "show.json", account: account)
  end
end
