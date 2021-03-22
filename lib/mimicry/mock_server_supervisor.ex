defmodule Mimicry.MockServerSupervisor do
  @moduledoc """
  The MockServer is the main entrypoint for creating servers on demand
  that will respond to other messages.
  """
  use GenServer

  alias Mimicry.MockServer

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
    children =
      servers
      |> Enum.map(fn spec ->
        id = create_id(spec)
        {:ok, pid} = GenServer.start_link(MockServer, [spec: spec, id: id], name: id)
        pid
      end)

    GenServer.start_link(__MODULE__, [servers: children], name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:list, _from, state) do
    servers =
      state
      |> Keyword.get(:servers)
      |> Enum.map(fn pid ->
        %{
          spec: :sys.get_state(pid) |> Keyword.get(:spec),
          id: :sys.get_state(pid) |> Keyword.get(:id)
        }
      end)

    {:reply, servers, state}
  end

  @impl true
  def handle_call(:create, _from, _state) do
    {:reply, [], []}
  end

  defp create_id(%{"info" => %{"title" => title, "version" => version}}) do
    :md5
    |> :crypto.hash("#{title}-#{version}")
    |> Base.encode16(case: :lower)
    |> String.to_atom()
  end
end
