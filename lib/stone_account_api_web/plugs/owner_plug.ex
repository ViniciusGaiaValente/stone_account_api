defmodule StoneAccountApiWeb.OwnerPlug do
  use StoneAccountApiWeb, :controller

  alias StoneAccountApi.Banking

  def init(_params) do

  end

  def call(%{ private: %{ guardian_default_resource: account_id } } = conn, _params) do
    case Banking.get_account_by_id(account_id) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "You are logged to an account that does not exist anymore, please sign in again."})
        |> halt()
      account ->
        conn
        |> assign(:signed_account, account)
    end
  end
end
