defmodule StoneAccountApiWeb.AccountView do
  use StoneAccountApiWeb, :view
  alias StoneAccountApiWeb.AccountView

  def render("index.json", %{accounts: accounts}) do
    %{data: render_many(accounts, AccountView, "account.json")}
  end

  def render("show.json", %{account: account}) do
    %{data: render_one(account, AccountView, "account.json")}
  end

  def render("account.json", %{account: account}) do
    %{id: account.id,
      number: account.number,
      balance: account.balance,
      holder: StoneAccountApiWeb.HolderView.render("holder.json", %{ holder: account.holder })}
  end
end
