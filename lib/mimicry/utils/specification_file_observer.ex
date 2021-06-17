defmodule Mimicry.Utils.SpecificationFileObserver do
  @moduledoc """
  Listens to changes in  the folder defined via `Mimicry.Utils.SpecificationFolder.base_path/0` and reloads
  the specifications currently running in mimicry
  """

  alias Mimicry.Utils.{SpecificationFileReader, SpecificationFolder}

  require Logger

  use GenServer

  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  @impl true
  def init(_args) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: [SpecificationFolder.base_path()])
    FileSystem.subscribe(watcher_pid)
    {:ok, %{watcher_pid: watcher_pid}}
  end

  @impl true
  def handle_info({:file_event, _watcher_pid, {path, events}}, state) do
    case SpecificationFileReader.extension(path) do
      extension when extension in [:yaml, :json] ->
        path |> handle_file_event(events)
        {:noreply, state}

      _ ->
        Logger.info("Saw new file in #{path}, but not a specification!")
        {:noreply, state}
    end
  end

  @impl true
  def handle_info({:file_event, _watcher_pid, :stop}, state) do
    {:noreply, state}
  end

  defp handle_file_event(path, [:deleted]) do
    IO.puts("Deleted #{path}")
  end

  defp handle_file_event(path, [:created]) do
    IO.puts("Created #{path}")
  end

  defp handle_file_event(path, [:modified, :closed]) do
    IO.puts("Modified #{path}")
  end

  defp handle_file_event(path, [:attribute]) do
    IO.puts("New content #{path}")
  end

  defp handle_file_event(path, [:moved_to]) do
    IO.puts("Moved file: #{path}")
  end

  defp handle_file_event(_path, unsupported_events) do
    unsupported_events |> IO.inspect()
  end
end
