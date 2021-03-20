defmodule Mimicry.Application do
  use Application
  alias MimicryParser.Loader

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      MimicryApi.Endpoint,
      # Start the supervisor for creating additional servers
      {Mimicry.MockServer, [%{servers: create_initial_servers()}]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mimicry.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MimicryApi.Endpoint.config_change(changed, removed)
    :ok
  end

  defp create_initial_servers(), do: Loader.load_from_spec_folder()
end
