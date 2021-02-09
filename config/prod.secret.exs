# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :stone_account_api, StoneAccountApi.Repo,
  # ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :stone_account_api, StoneAccountApiWeb.Endpoint,
  load_from_system_env: true,
  server: true,
  http: [
    port: String.to_integer(System.get_env("PORT") |> IO.inspect() || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  url: [
    host: System.get_env("HOST") |> IO.inspect() || "localhost",
    port: String.to_integer(System.get_env("PORT") |> IO.inspect() || "4000")
  ],
  secret_key_base: secret_key_base

jwt_key =
  System.get_env("JWT_KEY") ||
    raise """
    environment variable JWT_KEY is missing.
    """

config :stone_account_api, StoneAccountApi.Auth.Guardian,
  secret_key: jwt_key

mailgun_api_key =
  System.get_env("MAILGUN_API_KEY") ||
  raise """
  environment variable MAILGUN_API_KEY is missing.
  """

mailgun_domain =
  System.get_env("MAILGUN_DOMAIN") ||
  raise """
  environment variable MAILGUN_DOMAIN is missing.
  """

config :stone_account_api, StoneAccountApi.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: mailgun_api_key,
  domain: mailgun_domain,
  hackney_opts: [
    recv_timeout: :timer.minutes(1)
  ]

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :stone_account_api, StoneAccountApiWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
