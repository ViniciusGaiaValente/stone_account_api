defmodule StoneAccountApiWeb.HolderView do
  use StoneAccountApiWeb, :view
  alias StoneAccountApiWeb.HolderView

  def render("index.json", %{holders: holders}) do
    %{data: render_many(holders, HolderView, "holder.json")}
  end

  def render("show.json", %{holder: holder}) do
    %{data: render_one(holder, HolderView, "holder.json")}
  end

  def render("holder.json", %{holder: holder}) do
    %{id: holder.id,
      name: holder.name,
      email: holder.email,
      birthdate: holder.birthdate}
  end
end
