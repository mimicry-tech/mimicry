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
      """

      %Specification{
        content: content,
        title: "TestAPI",
        version: "1.0",
        openapi_version: "3.0.0"
      } = Parser.parse(str, :yaml)

      %Specification{
        content: ^content,
        title: "TestAPI",
        version: "1.0",
        openapi_version: "3.0.0"
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
        }
      }
      """

      %Specification{
        content: content,
        title: "TestAPI",
        version: "1.0",
        openapi_version: "3.0.0"
      } = Parser.parse(str, :json)

      %Specification{
        content: ^content,
        title: "TestAPI",
        version: "1.0",
        openapi_version: "3.0.0"
      } = Parser.json(str)

      assert {:ok, content} == Jason.decode(str)
    end
  end
end
