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
  parses a given string based on the extension to a Mimicry.Specifaction

  If you need a map instead of the specification, see parse_to_map/2
  """
  @spec parse(term(), :yaml | :json) :: Specification.t()
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
  parses a given string to a map
  """
  @spec parse_to_map(any(), :yaml | :json) :: :error | any()
  def parse_to_map(str, atom) do
    str
    |> decoder(atom).()
    |> case do
      {:ok, decoded} ->
        decoded

      {:error, err} ->
        Logger.warn("Could not decode #{atom |> to_string() |> String.upcase()} specification")
        Logger.error(err)
        :error
    end
  end

  @doc """
  builds a new Specification from inputs given
  """
  @spec build_specification(any()) :: Specification.t()
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

  def build_specification(spec = _) do
    Logger.warn("Specification most likely invalid", specification: spec)
    Specification.unsupported()
  end

  defp decoder(atom) do
    case atom do
      # NOTE: This cannot read multiple specifications in a YAML file as of yet
      :yaml -> &YamlElixir.read_from_string/1
      :json -> &Jason.decode/1
      _ -> raise RuntimeError, "Unknown extension: #{atom}"
    end
  end
end
