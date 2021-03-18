use Mix.Config

if Mix.env() == :dev do
  config :mix_test_watch,
    clear: true
end

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures the endpoint
config :mimicry, MimicryApi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2huvB6wFDsQJGkJYw5712sNJJeFD+itR0VApi8VLNNSFQZG79+Bv6FI6cPpbaCm/",
  render_errors: [
    view: MimicryApi.ErrorView,
    accepts: ~w(json)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
