defmodule StoneAccountApiWeb.TransferenceRegisterView do
  use StoneAccountApiWeb, :view
  alias StoneAccountApiWeb.TransferenceRegisterView

  def render("index.json", %{transference_registers: transference_registers}) do
    %{data: render_many(transference_registers, TransferenceRegisterView, "transference_register.json")}
  end

  def render("show.json", %{transference_register: transference_register}) do
    %{data: render_one(transference_register, TransferenceRegisterView, "transference_register.json")}
  end

  def render("transference_register.json", %{transference_register: transference_register}) do
    %{id: transference_register.id,
      origin_id: transference_register.origin_id,
      destination_id: transference_register.destination_id,
      origin_old_balance: Money.to_string(transference_register.origin_old_balance),
      origin_new_balance: Money.to_string(transference_register.origin_new_balance),
      destination_old_balance: Money.to_string(transference_register.destination_old_balance),
      destination_new_balance: Money.to_string(transference_register.destination_new_balance),
      value:  Money.to_string(transference_register.value)}
  end
end
