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
  def list_servers() do
    GenServer.call(__MODULE__, :list)
  end

  def create_server(spec = %{}) do
    GenServer.call(__MODULE__, {:create, spec})
  end

  def delete_server(id) do
    GenServer.call(__MODULE__, {:delete, id |> String.to_atom()})
  end

  def find_server(%{host: host}) do
    GenServer.call(__MODULE__, {:find, host})
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
      |> Keyword.get(:servers, [])
      |> Enum.map(fn pid ->
        pid |> :sys.get_state() |> Keyword.take([:spec, :id]) |> Enum.into(%{})
      end)

    {:reply, servers, state}
  end

  @impl true
  def handle_call({:create, spec}, _from, servers: servers) do
    id = create_id(spec)

    case GenServer.start_link(MockServer, [spec: spec, id: id], name: id) do
      {:ok, pid} ->
        # respond with the new server
        {:reply, {:ok, %{spec: spec, id: id}}, [servers: [pid | servers]]}

      {:error, {:already_started, _pid}} ->
        # respond with the existing server
        {:reply, {:ok, %{spec: spec, id: id}}, [servers: servers]}
    end
  end

  @impl true
  def handle_call({:delete, id}, _from, servers: servers) do
    servers
    |> Enum.map(&:sys.get_state(&1))
    |> Enum.filter(fn state -> state[:id] == id end)
    |> case do
      [] ->
        # nothing to do
        {:reply, [], [servers: servers]}

      [server] ->
        # remove the server and respond with it
        new_servers =
          servers
          |> Enum.map(&:sys.get_state(&1))
          |> Enum.filter(fn server -> server[:id] != id end)

        {:reply, server |> Keyword.take([:spec, :id]) |> Enum.into(%{}), [servers: new_servers]}
    end
  end

  @impl true
  def handle_call({:find, url}, _from, [servers: servers] = state) do
    servers
    |> Enum.map(&:sys.get_state(&1))
    |> Enum.filter(fn [spec: %{"servers" => hosts}, id: _id] ->
      hosts |> Enum.any?(fn spec_host -> spec_host["url"] == url end) |> IO.inspect()
    end)
    |> case do
      [_server | _hosts] ->
        {:reply, {:ok, url}, state}

      [] ->
        {:reply, {:error, nil}, state}
    end
  end

  defp create_id(%{"info" => %{"title" => title, "version" => version}}) do
    :md5
    |> :crypto.hash("#{title}-#{version}")
    |> Base.encode16(case: :lower)
    |> String.to_atom()
  end
end
