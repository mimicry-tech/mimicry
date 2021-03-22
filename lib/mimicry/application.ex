defmodule Mimicry.Application do
  use Application
  alias Mimicry.MockServerList

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      MimicryApi.Endpoint,
      # Start a dynamic supervisor for creating additional servers
      MockServerList,
      {Task, &MockServerList.seed_initial_servers/0}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :rest_for_one, name: Mimicry.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MimicryApi.Endpoint.config_change(changed, removed)
    :ok
  end
end
