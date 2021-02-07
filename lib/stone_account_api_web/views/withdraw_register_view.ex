defmodule StoneAccountApiWeb.WithdrawRegisterView do
  use StoneAccountApiWeb, :view
  alias StoneAccountApiWeb.WithdrawRegisterView

  def render("index.json", %{withdraw_registers: withdraw_registers}) do
    %{data: render_many(withdraw_registers, WithdrawRegisterView, "withdraw_register.json")}
  end

  def render("show.json", %{withdraw_register: withdraw_register}) do
    %{data: render_one(withdraw_register, WithdrawRegisterView, "withdraw_register.json")}
  end

  def render("withdraw_register.json", %{withdraw_register: withdraw_register}) do
    %{id: withdraw_register.id,
      old_balance: withdraw_register.old_balance,
      new_balance: withdraw_register.new_balance,
      value: withdraw_register.value}
  end
end
