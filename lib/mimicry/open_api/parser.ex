defmodule Mimicry.OpenAPI.Parser do
  @moduledoc """
  Parses a given OpenAPI Specification and gives access to the different parts of the spec more easily
  """

  alias Mimicry.OpenAPI.{Example, Specification}

  require Logger

  @doc """
  extracts an examples by its name
  """
  def example(%Specification{contents: contents} = _spec, name) do
    case contents |> _parse |> get_in(["components", "examples", name]) do
      nil -> {:error, :not_found}
      value -> {:ok, value |> Example.build()}
    end
  end

  defp _parse(yaml_str) do
    case yaml_str |> YamlElixir.read_from_string() do
      {:ok, decoded} ->
        decoded

      {:error, _} ->
        Logger.warn("Could not decode yaml specification")
        %{}
    end
  end
end
