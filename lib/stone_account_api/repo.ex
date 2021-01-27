defmodule StoneAccountApi.Repo do
  use Ecto.Repo,
    otp_app: :stone_account_api,
    adapter: Ecto.Adapters.Postgres
end
