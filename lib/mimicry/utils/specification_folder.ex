defmodule Mimicry.Utils.SpecificationFolder do
  @moduledoc """
  Contains functions loading the spec files from the spec folder, deduping them
  """

  require Logger

  @load_file_types "/*.{yaml,yml,json}"

  alias Mimicry.Utils.SpecificationFileReader, as: FileReader
  alias Mimicry.OpenAPI.{Parser, Specification}

  @doc """
  Will attempt to load all specifications in the configured folder
  while preserving paths with the specifications
  """
  @spec load_all() :: list()
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
    |> Enum.map(&Task.async(fn -> load(&1) end))
    |> Task.await_many()
    |> Enum.filter(fn {status, _, _} -> status != :error end)
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
        specification = Parser.parse(content, ext)
        {:ok, specification, path}

      nil ->
        Logger.warn("Found invalid specification in Specification folder: #{path}")
        {:error, nil, path}
    end
  end

  defp deduplicate([]), do: []

  defp deduplicate(servers) do
    servers
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.uniq_by(&duplicate_condition/1)
  end

  defp duplicate_condition({%Specification{title: title, version: version}, _}) do
    "#{title}-#{version}"
  end

  defp duplicate_condition(_), do: 0
end
