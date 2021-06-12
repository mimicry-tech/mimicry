defmodule Mimicry.Utils.SpecificationFileReaderTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Mimicry.Utils.SpecificationFileReader, as: File
  alias Mimicry.Utils.SpecificationFolder, as: Folder

  describe "read/1" do
    test "reads a given file, extracting the format as YAML correctly" do
      path = Folder.base_path() |> Path.join("simple.yaml")
      {:ok, _file_content, :yaml} = File.read(path)
    end

    test "reads a given file, extracting the extension as JSON correctly" do
      path = Folder.base_path() |> Path.join("simple.json")
      {:ok, _file_content, :json} = File.read(path)
    end

    test "errors when file does not exist" do
      {:error, :enoent} = File.read("non_existing.yaml")
    end
  end
end
