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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
