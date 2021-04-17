defmodule Mimicry.MockServerList do
  @moduledoc """
  The `MockServerList` is the main entrypoint for creating servers on demand
  that will respond to other messages.

  Based on a `DynamicSupervisor`, this allows add hoc adding/removing of MockServers on demand
  """
  use DynamicSupervisor

  require Logger

  alias Mimicry.MockServer

  ## Boundary

  @doc """
  retrieves the list of currently available servers
  """
  def list_servers() do
    children()
    |> Enum.map(&state/1)
  end

  @doc """
  creates a new MockServer started under the `DynamicSupervisor`

  Idempotent, this will not create a duplicate for the same combination of `title` + `version`.
  """
  @spec create_server(map()) :: {:ok, pid()} | {:error, :invalid_specification}
  def create_server(spec) do
    case start_mock_server(spec) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:error, _, _message} -> {:error, :invalid_specification}
    end
  end

  @doc """
  Deletes a server given an `id` - the `id` in question needs to be one of the generated IDs
  """
  def delete_server(id) do
    children()
    |> Enum.filter(fn pid ->
      id |> to_string() == pid |> :sys.get_state() |> Keyword.get(:id) |> to_string()
    end)
    |> Enum.map(fn pid ->
      last_state = pid |> state()
      :ok = DynamicSupervisor.terminate_child(__MODULE__, pid)
      last_state
    end)
  end

  @doc """
  Looks up a mock server based on the host passed.host
  A given host will match as long as one of its hosts matches _exactly_
  """
  @spec find_server(String.t()) :: {:ok, pid()} | {:error, :not_found}
  def find_server(url) do
    children()
    |> Enum.map(fn pid ->
      {pid, pid |> :sys.get_state() |> Keyword.get(:spec)}
    end)
    |> Enum.filter(fn {_, %{"servers" => hosts}} ->
      hosts |> Enum.any?(fn %{"url" => host_url} -> host_url == url end)
    end)
    |> case do
      [{server, _spec} | _hosts] -> {:ok, server}
      [] -> {:error, :not_found}
    end
  end

  @doc """
  used to seed initial servers given via the spec folder
  """
  def seed_initial_servers() do
    MimicryParser.Loader.load_from_spec_folder()
    |> Enum.each(&start_mock_server/1)
  end

  ## /Boundary

  def start_link(state) do
    DynamicSupervisor.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp start_mock_server(spec) do
    try do
      child_spec = spec |> MockServer.create_id() |> MockServer.child_spec(spec)
      DynamicSupervisor.start_child(__MODULE__, child_spec)
    rescue
      e in RuntimeError ->
        Logger.error(e.message, spec: spec)
        {:error, :invalid_spec, e.message}
    end
  end

  defp children() do
    DynamicSupervisor.which_children(__MODULE__)
    # NOTE: DynamicSupervisor children are all `:undefined` in respect for their ids
    |> Enum.map(fn {:undefined, pid, _, _} -> pid end)
  end

  defp state(pid) do
    pid |> :sys.get_state() |> Keyword.take([:id, :entities, :spec]) |> Enum.into(%{})
  end
end
