defmodule Mimicry.OpenAPISpecificationCase do
  use ExUnit.CaseTemplate
  alias Mimicry.OpenAPI.Parser
  alias Mimicry.Utils.{SpecificationFileReader, SpecificationFolder}

  require Logger

  setup context do
    if file = Map.get(context, :specification, false) do
      case SpecificationFolder.base_path() |> Path.join(file) |> SpecificationFileReader.read() do
        {:ok, content, extension} ->
          spec = Parser.parse(content, extension)
          {:ok, %{specification: spec}}

        _ ->
          Logger.warn("Fixture #{file} not found in #{SpecificationFolder.base_path()}")
          :ok
      end
    else
      :ok
    end
  end
end
