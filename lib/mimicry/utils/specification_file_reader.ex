defmodule Mimicry.Utils.SpecificationFileReader do
  @moduledoc """
  `SpecificationFileReader` provides functions around fiels given to Mimicry.
  """

  @doc """
  attempts to read a file from the configured spec directory,
  retaining information about the extension of the file

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
  Returns the file extension as an atom in order to determine which parser is used further
  down the road.
  """
  @spec extension(String.t()) :: atom()
  def extension(file) do
    case file |> Path.extname() do
      ".yaml" -> :yaml
      ".yml" -> :yaml
      ".json" -> :json
      _ -> :unsupported
    end
  end
end
