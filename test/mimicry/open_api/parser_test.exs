defmodule Mimicry.OpenAPI.ParserTest do
  use ExUnit.Case

  alias Mimicry.OpenAPI.{
    Parser,
    Specification
  }

  describe "parse/2" do
    test "when the str is YAML" do
      str = """
      openapi: 3.0.0
      components:
        examples:
          my_example:
            summary: An example example
            value: '{"message": "example"}'
      info:
        title: 'TestAPI'
        version: '1.0'
      servers: []
      """

      %Specification{
        content: content,
        title: "TestAPI",
        version: "1.0",
        openapi_version: "3.0.0",
        servers: []
      } = Parser.parse(str, :yaml)

      %Specification{
        content: ^content,
        title: "TestAPI",
        version: "1.0",
        openapi_version: "3.0.0",
        servers: []
      } = Parser.yaml(str)

      assert {:ok, content} == YamlElixir.read_from_string(str)
    end

    test "when the string is JSON" do
      str = """
      {
        "openapi": "3.0.0",
        "components": {
          "examples": {
            "my_example": {
              "summary": "An example example",
              "value": "{'message': 'example'}"
            }
          }
        },
        "info": {
          "title": "TestAPI",
          "version": "1.0"
        },
        "servers": []
      }
      """

      %Specification{
        content: content,
        title: "TestAPI",
        version: "1.0",
        openapi_version: "3.0.0",
        servers: []
      } = Parser.parse(str, :json)

      %Specification{
        content: ^content,
        title: "TestAPI",
        version: "1.0",
        openapi_version: "3.0.0",
        servers: []
      } = Parser.json(str)

      assert {:ok, content} == Jason.decode(str)
    end
  end

  describe "build_specification/1" do
    test "when the spec given doesn't match expectations" do
      spec = %{"foobar" => "baz"} |> Parser.build_specification()

      refute spec.supported
    end

    test "when the spec matches expectations" do
      definition = %{
        "openapi" => "3.0.0",
        "info" => %{"title" => "myFreshNewApi", "version" => "1.0.0alpha"},
        "servers" => [
          %{"url" => "https://fresh-api.testing.com"}
        ],
        "paths" => [%{"/" => %{}}]
      }

      spec =
        %Specification{openapi_version: "3.0.0", title: "myFreshNewApi"} =
        definition |> Parser.build_specification()

      assert spec.supported
    end
  end
end
