# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# 注释掉 Ecto repo 配置
# config :scorpius_sonnet,
#   ecto_repos: [ScorpiusSonnet.Repo]

config :scorpius_sonnet,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :scorpius_sonnet, ScorpiusSonnetWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ScorpiusSonnetWeb.ErrorHTML, json: ScorpiusSonnetWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ScorpiusSonnet.PubSub,
  live_view: [signing_salt: "AXze0S27"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :scorpius_sonnet, ScorpiusSonnet.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# 添加 Vite 配置
config :vite_phx,
  release_app: :scorpius_sonnet,
  environment: Mix.env(),
  vite_manifest: "priv/static/manifest.json"
