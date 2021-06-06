use Mix.Config

# sets the config folder differently fo the test environment
config :mimicry, Mimicry.Utils.SpecificationFolder, path: "./test/fixtures/specs"

# forces mimicry to not load specs on startup
config :mimicry, Mimicry.MockServerList, load_specification_files_on_startup: false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mimicry, MimicryApi.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
