defmodule StoneAccountApiWeb.Router do
  use StoneAccountApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug StoneAccountApiWeb.AuthPlug
  end

  pipeline :owner do
    plug StoneAccountApiWeb.OwnerPlug
  end

  scope "/api", StoneAccountApiWeb do
    pipe_through :api

    post "/accounts/signup", AccountController, :create
    get "/accounts/signin", AccountController, :signin
  end

  scope "/api", StoneAccountApiWeb do
    pipe_through [:api, :auth, :owner]

    get "/accounts/:number", AccountController, :show
    post "/trasnference", TransferenceController, :transfer
    post "/withdraw", WithdrawController, :withdraw
  end

  scope "/api/backoffice", StoneAccountApiWeb do
    pipe_through :api

    get "/withdraws", WithdrawRegisterController, :index
    get "/transferences", TransferenceRegisterController, :index

    get "/report/day", ReportController, :day
    get "/report/month", ReportController, :month
    get "/report/year", ReportController, :year
  end
end
