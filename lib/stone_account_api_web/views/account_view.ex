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
      balance: %{
        precise: account.balance.amount,
        decimal: Money.to_decimal(account.balance),
        display: Money.to_string(account.balance, fractional_unit: true),
      },
      holder: StoneAccountApiWeb.HolderView.render("holder.json", %{ holder: account.holder })}
  end

  def render("create_account_response.json", %{account: account, token: token}) do
    %{
      account:
      %{
        id: account.id,
        number: account.number,
        balance: %{
          precise: account.balance.amount,
          decimal: Money.to_decimal(account.balance),
          display: Money.to_string(account.balance, fractional_unit: true),
        },
        holder: StoneAccountApiWeb.HolderView.render("holder.json", %{ holder: account.holder })
      },
      token: token
    }
  end
end
