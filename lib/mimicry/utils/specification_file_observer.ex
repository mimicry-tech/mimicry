defmodule Mimicry.Utils.SpecificationFileObserver do
  @moduledoc """
  Listens to changes in  the folder defined via `Mimicry.Utils.SpecificationFolder.base_path/0` and reloads
  the specifications currently running in mimicry
  """

  alias Mimicry.MockServerList
  alias Mimicry.OpenAPI.Parser
  alias Mimicry.Utils.{SpecificationFileReader, SpecificationFolder}

  require Logger

  use GenServer

  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  @impl true
  def init(_args) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: [SpecificationFolder.base_path()])
    watcher_pid |> FileSystem.subscribe()
    {:ok, %{watcher_pid: watcher_pid}}
  end

  @impl true
  def handle_info({:file_event, _watcher_pid, {path, events}}, state) do
    Logger.metadata(path: path, events: events)

    case SpecificationFileReader.extension(path) do
      extension when extension in [:yaml, :json] ->
        path |> handle_file_event(events)
        {:noreply, state}

      :unsupported ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_info({:file_event, _watcher_pid, :stop}, state) do
    {:noreply, state}
  end

  defp handle_file_event(path, [:moved_from]) do
    case path |> Path.basename() |> MockServerList.find_server_by_specification_path() do
      {:ok, pid} ->
        Logger.info("Removing")
        pid |> MockServerList.delete_server()

      _ ->
        nil
    end
  end

  defp handle_file_event(path, [:modified, :closed]) do
    path
    |> parse()
    |> upsert(path)
  end

  defp handle_file_event(path, [:moved_to]) do
    path
    |> parse()
    |> upsert(path)
  end

  defp handle_file_event(_path, _events) do
    Logger.info("Unknown")
  end

  defp parse(path) do
    {:ok, content, ext} = path |> SpecificationFileReader.read()
    Parser.parse(content, ext)
  end

  defp upsert(spec, path) do
    case path
         |> Path.basename()
         |> MockServerList.find_server_by_specification_path() do
      {:ok, pid} ->
        Logger.info("Reloading...")

        pid |> MockServerList.update_server_specification(spec)

      _ ->
        Logger.info("Creating...")
        spec |> MockServerList.create_server(path)
    end
  end
end
