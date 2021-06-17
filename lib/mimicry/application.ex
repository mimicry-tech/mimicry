defmodule Mimicry.Application do
  @moduledoc """
  The main Mimicry Application will start a set of mock servers.

  These servers will be bootstrapped from the specs folder, and initialized via a single
  `Task` run concurrently to the `Mimicry.MockServerList` itself.

  """
  use Application
  alias Mimicry.MockServerList
  alias Mimicry.Utils.SpecificationFileObserver

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      MimicryApi.Endpoint,
      # Start a dynamic supervisor for creating additional servers
      MockServerList,
      # starts one task to trigger the initial seeds given in ./specs
      {Task, &MockServerList.load_specifications_on_startup/0},
      # starts a file observer that watches the configured spec folder for changes
      SpecificationFileObserver
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
