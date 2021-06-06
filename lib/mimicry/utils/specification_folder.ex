defmodule Mimicry.Utils.SpecificationFolder do
  @moduledoc """
  Contains functions loading the spec files from the spec folder, deduping them
  """

  require Logger

  @load_file_types "/*.{yaml,yml,json}"

  alias Mimicry.Utils.SpecificationFileReader, as: FileReader

  @doc """
  will attempt to load all specifications in the configured folder
  """
  def load_all do
    if base_path() |> File.dir?() do
      load_all_deduplicated()
    else
      Logger.warn("No specifications found in #{base_path()}!")
      []
    end
  end

  @doc """
  returns the configured base path for the folder holding the OpenAPI specifications trying to remove any duplications
  """
  def base_path do
    Application.get_env(:mimicry, __MODULE__, [])
    |> Keyword.get(:path, File.cwd!())
  end

  defp load_all_deduplicated do
    base_path()
    |> Path.join(@load_file_types)
    |> Path.wildcard()
    |> Enum.map(&Path.basename/1)
    |> Enum.map(fn path ->
      Task.async(fn -> load_file(path) |> FileReader.load_into_spec() end)
    end)
    |> Task.await_many()
    |> FileReader.deduplicate()
  end

  defp load_file(path) do
    base_path()
    |> Path.join(path)
    |> FileReader.read()
    |> case do
      {:ok, spec, extension} ->
        {spec, extension}

      _ ->
        nil
    end
  end
end
