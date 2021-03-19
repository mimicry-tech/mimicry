defmodule Mimicry.MockServer do
  @moduledoc """
  The MockServer is the main entrypoint for creating servers on demand
  that will respond to other messages.
  """
  use GenServer

  @doc """
  retrieves the list of currently available servers
  """
  def list_servers(_params \\ %{}) do
    GenServer.call(__MODULE__, :list)
  end

  def create_server(_params = %{}) do
    GenServer.call(__MODULE__, :create)
  end

  @doc """
  starts the Mock Server Supervisor, which is used to start other processes
  representing individually created mock servers for users.
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:list, _from, _state) do
    {:reply, [], []}
  end

  def handle_call(:create, _from, _state) do
    {:reply, [], []}
  end
end
