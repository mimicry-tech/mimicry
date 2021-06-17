defmodule Mimicry.MockServerList do
  @moduledoc """
  The `MockServerList` is the main entrypoint for creating servers on demand
  that will respond to other messages.

  Based on a `DynamicSupervisor`, this allows add hoc adding/removing of MockServers on demand
  """
  use DynamicSupervisor

  require Logger

  alias Mimicry.MockServer
  alias Mimicry.OpenAPI.Specification
  alias Mimicry.Utils.SpecificationFolder, as: SpecFolder

  ## Boundary

  @doc """
  retrieves the list of currently available servers
  """
  def list_servers do
    children()
    |> Enum.map(&state/1)
  end

  @doc """
  creates a new MockServer started under the `DynamicSupervisor`

  Idempotent, this will not create a duplicate for the same combination of `title` + `version`.
  """
  @spec create_server(Specification.t(), String.t()) ::
          {:ok, pid()} | {:error, :invalid_specification} | {:error, :unknown}
  def create_server(spec, file \\ "") do
    case spec |> start_mock_server(file) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:error, :invalid_specification} -> {:error, :invalid_specification}
      {:error, _} -> {:error, :unknown}
    end
  end

  @doc """
  Deletes a server given an `id` - the `id` in question needs to be one of the generated IDs or a valid child pid
  """
  @spec delete_server(atom() | String.t() | pid()) :: list()
  def delete_server(value)

  def delete_server(pid) when is_pid(pid) do
    children()
    |> Enum.filter(fn child_pid -> child_pid == pid end)
    |> Enum.map(fn pid ->
      last_state = pid |> state()
      :ok = DynamicSupervisor.terminate_child(__MODULE__, pid)
      last_state
    end)
  end

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
  Removes all servers from the list
  """
  @spec clear_servers() :: :ok
  def clear_servers do
    children()
    |> Enum.each(fn pid ->
      DynamicSupervisor.terminate_child(__MODULE__, pid)
    end)

    :ok
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
    |> Enum.filter(fn {_, %Specification{servers: hosts}} ->
      hosts |> Enum.any?(fn %{"url" => host_url} -> host_url == url end)
    end)
    |> case do
      [{server, _spec} | _hosts] -> {:ok, server}
      [] -> {:error, :not_found}
    end
  end

  def find_server_by_specification_path(path) do
    children()
    |> Enum.find(fn pid ->
      pid |> :sys.get_state() |> Keyword.get(:path) == path
    end)
    |> case do
      nil ->
        {:error, :not_found}

      pid ->
        {:ok, pid}
    end
  end

  def update_server_specification(pid, spec = %Specification{}) do
    pid |> MockServer.update_server_specification(spec)
  end

  @doc """
  used to seed servers given via the spec folder upon startup
  """
  def load_specifications_on_startup do
    enabled? =
      Application.get_env(:mimicry, __MODULE__, [])
      |> Keyword.get(:load_specification_files_on_startup, true)

    enabled? |> do_load_specification_on_startup()
  end

  ## /Boundary

  def start_link(state) do
    DynamicSupervisor.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp start_mock_server({_, _spec = %Specification{supported: false}, _}) do
    {:error, :unsupported_spec}
  end

  defp start_mock_server({:ok, spec = %Mimicry.OpenAPI.Specification{}, file_path}) do
    child_spec = spec |> MockServer.create_id() |> MockServer.child_spec(spec, file_path)

    case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:error, _} ->
        :error

      value ->
        value
    end
  end

  defp start_mock_server(_, _), do: {:error, :invalid_specification}

  defp children do
    DynamicSupervisor.which_children(__MODULE__)
    # NOTE: DynamicSupervisor children are all `:undefined` in respect for their ids
    |> Enum.map(fn {:undefined, pid, _, _} -> pid end)
  end

  defp state(pid) do
    pid |> :sys.get_state() |> Keyword.take([:id, :entities, :spec]) |> Enum.into(%{})
  end

  defp do_load_specification_on_startup(enabled?) when enabled? == true do
    SpecFolder.load_all()
    |> Enum.each(&start_mock_server/1)
  end

  defp do_load_specification_on_startup(_), do: nil
end
