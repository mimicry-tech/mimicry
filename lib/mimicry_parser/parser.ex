defmodule MimicryParser.Parser do
  alias Mimicry.OpenAPI.Specification

  @spec read(String.t()) :: {:ok, %Specification{}} | {:error, atom() | nil}

  def read(file) do
    file_path = base_path() |> Path.expand() |> Path.join(file)

    case File.read(file_path) do
      {:ok, file} ->
        {:ok, %Specification{original_file: file_path, file: file}}

      {:error, code} ->
        {:error, code}
    end
  end

  @doc """
  Gets the path to read specifications from, falls back to File.cwd!/0
  """
  def base_path do
    Application.get_env(:mimicry, __MODULE__)
    |> Keyword.get(:folder, File.cwd!())
  end
end
