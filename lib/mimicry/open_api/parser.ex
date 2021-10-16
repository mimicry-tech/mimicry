defmodule Mimicry.OpenAPI.Parser do
  @moduledoc """
  Parses a given OpenAPI Specification and gives access to the different parts of the spec more easily
  """

  alias Mimicry.OpenAPI.Specification

  require Logger

  @doc """
  shorthand for parse(str, :yaml)
  """
  def yaml(str), do: parse(str, :yaml)

  @doc """
  shorthand for parse(str, :json)
  """
  def json(str), do: parse(str, :json)

  @doc """
  parses a given string depending on its extension
  """
  @spec parse(String.t(), :yaml | :json) :: Specification.t()
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
          "info" => info,
          "openapi" => openapi_version,
          "servers" => servers
        }
      ) do
    %Specification{
      version: info["version"],
      title: info["title"],
      openapi_version: openapi_version,
      servers: servers,
      content: parsed
    }
  end

  def build_specification(_) do
    Specification.unsupported()
  end

  defp decoder(atom) do
    case atom do
      # NOTE: This cannot read multiple specifications in a YAML file as of yet
      :yaml -> &YamlElixir.read_from_string/1
      :json -> &Jason.decode/1
    end
  end
end
