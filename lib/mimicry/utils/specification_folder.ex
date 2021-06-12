defmodule Mimicry.Utils.SpecificationFolder do
  @moduledoc """
  Contains functions loading the spec files from the spec folder, deduping them
  """

  require Logger

  @load_file_types "/*.{yaml,yml,json}"

  alias Mimicry.Utils.SpecificationFileReader, as: FileReader
  alias Mimicry.OpenAPI.{Parser, Specification}

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
      Task.async(fn -> load(path) end)
    end)
    |> Task.await_many()
    |> Enum.filter(fn val -> val != :error end)
    |> deduplicate()
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

  defp load(path) do
    case load_file(path) do
      {content, ext} ->
        Parser.parse(content, ext)

      nil ->
        Logger.warn("Found invalid specification in Specification folder: #{path}")
        :error
    end
  end

  defp deduplicate([]), do: []

  defp deduplicate(servers) do
    servers
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.uniq_by(&duplicate_condition/1)
  end

  defp duplicate_condition(%Specification{title: title, version: version}) do
    "#{title}-#{version}"
  end

  defp duplicate_condition(_), do: 0
end
