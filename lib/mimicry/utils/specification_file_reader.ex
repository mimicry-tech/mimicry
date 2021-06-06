defmodule Mimicry.Utils.SpecificationFileReader do
  @moduledoc """
  the Parser module contains functions to read specifications from YAML or JSON
  """
  alias Mimicry.OpenAPI.{Parser, Specification}

  @doc """
  attempts to read a file from the configured spec directory

  see config/*.exs options
  """
  @spec read(String.t()) :: {:ok, String.t(), atom()} | {:error, atom()}
  def read(file) do
    case File.read(file) do
      {:ok, content} ->
        {:ok, content, extension(file)}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  transforms content into a `Mimicry.OpenAPI.Specification`
  """
  @spec load_into_spec(String.t(), atom()) :: Specification.t()
  def load_into_spec(spec, extension)

  def load_into_spec(content, extension) when is_binary(content),
    do: Parser.parse(content, extension)

  def load_into_spec(_, _), do: unsupported_spec()

  @doc """
  shorthand for passing tuple
  """
  @spec load_into_spec(tuple()) :: Specification.t()
  def load_into_spec({spec, extension}), do: load_into_spec(spec, extension)
  def load_into_spec(_), do: unsupported_spec()

  @doc """
  Removes duplicate servers from a list

  For now, the server with the same titles are considered duplicates
  """
  @spec deduplicate(list()) :: list()
  def deduplicate([]), do: []

  def deduplicate(servers) do
    servers
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.uniq_by(&duplicate_condition/1)
  end

  defp duplicate_condition(%Specification{title: title, version: version}) do
    "#{title}-#{version}"
  end

  defp duplicate_condition(_), do: 0

  defp extension(file) do
    case file |> Path.extname() do
      ".yaml" -> :yaml
      ".yml" -> :yaml
      ".json" -> :json
      _ -> :unsupported
    end
  end

  defp unsupported_spec,
    do: Specification.unsupported()
end
