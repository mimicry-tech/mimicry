defmodule Mimicry.OpenAPI.Parser do
  @moduledoc """
  Parses a given OpenAPI Specification and gives access to the different parts of the spec more easily
  """

  alias Mimicry.OpenAPI.Specification

  require Logger

  def yaml(str), do: parse(str, :yaml)
  def json(str), do: parse(str, :json)

  def parse(str, atom) do
    str
    |> decoder(atom).()
    |> case do
      {:ok, decoded} ->
        decoded |> build_specification()

      {:error, err} ->
        Logger.warn("Could not decode #{atom |> to_string() |> String.upcase()} specification")
        Logger.error(err)
        Specification.unsupported()
    end
  end

  @doc """
  builds a new Specification from inputs given
  """
  @spec build_specification(map()) :: Specification.t()
  def build_specification(
        parsed = %{
          "openapi" => openapi_version,
          "info" => %{"version" => v, "title" => title},
          "servers" => servers
        }
      ) do
    %Specification{
      version: v,
      title: title,
      openapi_version: openapi_version,
      servers: servers,
      content: parsed
    }
  end

  def build_specification(_), do: Specification.unsupported()

  defp decoder(atom) do
    case atom do
      # NOTE: This cannot read multiple specifications in a YAML file as of yet
      :yaml -> &YamlElixir.read_from_string/1
      :json -> &Jason.decode/1
    end
  end
end
