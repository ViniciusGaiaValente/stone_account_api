FROM bitwalker/alpine-elixir-phoenix:latest

WORKDIR /app

# CMD mix deps.get && mix ecto.reset && mix phx.server
CMD mix deps.get && mix ecto.create && mix ecto.migrate && mix phx.server