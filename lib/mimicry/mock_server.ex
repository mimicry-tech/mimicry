defmodule Mimicry.MockServer do
  @moduledoc """
  The MockServer is the main entrypoint for creating servers on demand
  that will respond to other messages.
  """
  use GenServer

  ## Boundary

  @doc """
  retrieves the list of currently available servers
  """
  def list_servers(_params \\ %{}) do
    GenServer.call(__MODULE__, :list)
  end

  def create_server(_params = %{}) do
    GenServer.call(__MODULE__, :create)
  end

  ## /Boundary

  ## GenServer Callbacks

  @doc """
  starts the Mock Server Supervisor, which is used to start other processes
  representing individually created mock servers for users.
  """
  def start_link([%{servers: servers}]) do
    GenServer.start_link(__MODULE__, [servers: servers], name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:list, _from, state) do
    servers = state |> Keyword.get(:servers)
    {:reply, servers, state}
  end

  @impl true
  def handle_call(:create, _from, _state) do
    {:reply, [], []}
  end
end
