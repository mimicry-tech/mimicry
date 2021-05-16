use Mix.Config

# Default bind and port for production
config :mimicry, MimicryApi.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 8080],
  server: true

# Start log-level in notice by default to reduce output
config :logger, level: :notice

# The in container folder specifications will be read from upon start up
config :mimicry, MimicryParser.Parser, folder: "/specifications"
