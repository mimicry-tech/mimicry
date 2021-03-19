use Mix.Config

config :mimicry, MimicryParser.Parser, folder: "./test/fixtures/specs"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mimicry, MimicryApi.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
