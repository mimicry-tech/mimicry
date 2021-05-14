defmodule MimicryParser.ParserTest do
  use ExUnit.Case, async: true

  alias Mimicry.OpenAPI.Specification
  alias MimicryParser.Parser

  describe "read/1" do
    test "reads a given file" do
      {:ok, %Specification{original_file: _}} = Parser.read("simple.yaml")
    end

    test "errors when file does not exist" do
      {:error, :enoent} = Parser.read("non_existing.yaml")
    end
  end

  describe "parse/1" do
    test "reads a JSON file" do
      {:ok, file} = Parser.read("simple.json")
      spec = file |> Parser.parse()

      assert(spec["openapi"] == "3.0.0")
    end

    test "reads a YAML file" do
      {:ok, file} = Parser.read("simple.yaml")
      spec = file |> Parser.parse()

      assert(spec["openapi"] == "3.0.0")
    end
  end
end
