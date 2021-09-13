defmodule Fixtures do
  @moduledoc false

  alias Mimicry.Utils.{SpecificationFileReader, SpecificationFolder}

  def load_fixture(file) do
    case SpecificationFolder.base_path() |> Path.join(file) |> SpecificationFileReader.read() do
      {:ok, content, _extension} -> content
      _ -> raise RuntimeError, message: "Fixture #{file} not found!"
    end
  end
end
