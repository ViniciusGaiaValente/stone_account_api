defmodule StoneAccountApiWeb.AuthPlug do
  use Guardian.Plug.Pipeline, otp_app: :stone_account_api,
    module: StoneAccountApi.Auth.Guardian,
    error_handler: StoneAccountApi.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
