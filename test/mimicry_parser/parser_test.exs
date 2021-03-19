defmodule MimicryParser.ParserTest do
  use ExUnit.Case, async: true

  alias MimicryParser.Parser
  alias Mimicry.OpenAPI.Specification

  describe "parse/1" do
    test "reads a given file" do
      {:ok, %Specification{original_file: _}} = Parser.read("simple.yaml")
    end

    test "errors when file does not exist" do
      {:error, :enoent} = Parser.read("non_existing.yaml")
    end
  end
end
