use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :stone_account_api, StoneAccountApi.Repo,
  username: "postgres",
  password: "postgres",
  database: "stone_account_api_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :stone_account_api, StoneAccountApiWeb.Endpoint,
  http: [port: 4002],
  server: false

# We don't run a server during test. If one is required,
config :bcrypt_elixir, log_rounds: 4

# Print only warnings and errors during test
config :logger, level: :warn
