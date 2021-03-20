defmodule MimicryParser.Loader do
  @moduledoc """
  loads the spec files from the spec folder, deduping them
  """

  require Logger

  @load_file_types "/*.{yaml,yml,json}"

  alias MimicryParser.Parser

  def load_from_spec_folder() do
    if Parser.base_path() |> File.dir?() do
      load_specifications(Parser.base_path())
    else
      Logger.warn("No specifications found in #{Parser.base_path()}!")
      []
    end
  end

  defp load_specifications(path) do
    path
    |> Path.join(@load_file_types)
    |> Path.wildcard()
    |> Enum.map(&Path.basename/1)
    |> Enum.map(fn path ->
      Task.async(fn -> load_file(path) |> Parser.parse() end)
    end)
    |> Task.await_many()
    |> Parser.deduplicate()
  end

  def load_file(path) do
    case Parser.read(path) do
      {:ok, spec} ->
        spec

      _ ->
        nil
    end
  end
end
