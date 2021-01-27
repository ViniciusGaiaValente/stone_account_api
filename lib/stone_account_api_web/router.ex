defmodule StoneAccountApiWeb.Router do
  use StoneAccountApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", StoneAccountApiWeb do
    pipe_through :api
  end
end
