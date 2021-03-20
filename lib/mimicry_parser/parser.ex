defmodule MimicryParser.Parser do
  alias Mimicry.OpenAPI.Specification

  @doc """
  attempts to read a file from the configured spec directory

  see config/*.exs options
  """
  @spec read(String.t()) :: {:ok, %Specification{}} | {:error, atom() | nil}
  def read(file) do
    file_path = base_path() |> Path.expand() |> Path.join(file)

    case File.read(file_path) do
      {:ok, contents} ->
        {:ok,
         %Specification{original_file: file_path, contents: contents, extension: extension(file)}}

      {:error, code} ->
        {:error, code}
    end
  end

  @spec parse(Specification.t()) :: map() | nil
  def parse(spec)

  def parse(nil), do: nil

  def parse(_spec = %Specification{contents: contents, extension: :yaml}) do
    case contents |> YamlElixir.read_from_string() do
      {:ok, decoded} ->
        decoded

      {:error, _} ->
        nil
    end
  end

  def parse(_spec = %Specification{contents: contents, extension: :json}) do
    case contents |> Jason.decode() do
      {:ok, decoded} -> decoded
      {:error, _} -> nil
    end
  end

  def parse(_), do: nil

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

  defp duplicate_condition(%{"info" => %{"title" => title}}), do: title
  defp duplicate_condition(_), do: 0

  @doc """
  Gets the path to read specifications from, falls back to File.cwd!/0

  Uses the `:folder` configuration to determine the path used for reading specifications
  """
  def base_path do
    Application.get_env(:mimicry, __MODULE__)
    |> Keyword.get(:folder, File.cwd!())
  end

  defp extension(file) do
    case file |> Path.extname() do
      ".yaml" -> :yaml
      ".yml" -> :yaml
      ".json" -> :json
      _ -> :unsupported
    end
  end
end
