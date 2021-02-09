# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :stone_account_api,
  ecto_repos: [StoneAccountApi.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :stone_account_api, StoneAccountApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "RtJ1x9iL/sL+M7GYYkddxLpxr5gY2TWvJqnhkue5WlDragGkClRcAU9e9Bl3wDXg",
  render_errors: [view: StoneAccountApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: StoneAccountApi.PubSub,
  live_view: [signing_salt: "EtMqojOb"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :money,
  default_currency: :BRL,           # this allows you to do Money.new(100)
  separator: ".",                   # change the default thousands separator for Money.to_string
  delimiter: ",",                   # change the default decimal delimeter for Money.to_string
  symbol: true,                     # don’t display the currency symbol in Money.to_string
  symbol_on_right: false,           # position the symbol
  symbol_space: false,              # add a space between symbol and number
  fractional_unit: true,            # display units after the delimeter
  strip_insignificant_zeros: false  # don’t display the insignificant zeros or the delimeter

config :stone_account_api, StoneAccountApi.Auth.Guardian,
  issuer: "stone_account_api",
  secret_key: "1MhEzwneZ+tY5qf4taOACxhgvg2340OmIFNTVykbIkiIkF+LnKgfJd3bXioNWD9v"

config :stone_account_api, StoneAccountApi.Email.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: System.get_env("MAILGUN_API_KEY"),
  domain: System.get_env("MAILGUN_DOMAIN"),
  hackney_opts: [
    recv_timeout: :timer.minutes(1)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
