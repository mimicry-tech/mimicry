defmodule Mimicry.Utils.SpecificationFileReaderTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Mimicry.OpenAPI.Specification
  alias Mimicry.Utils.SpecificationFileReader, as: FileReader

  describe "read/1" do
    test "reads a given file" do
      {:ok, _} = FileReader.read("simple.yaml")
    end

    test "errors when file does not exist" do
      {:error, :enoent} = FileReader.read("non_existing.yaml")
    end
  end

  describe "load_into_spec/2" do
    test "transforms a JSON file into a specification" do
      json = """
      {
        "openapi": "3.0.0",
        "info": {
          "title": "Test JSON",
          "version": "1.0",
          "license": {
            "name": "MIT"
          },
          "description": "A simple API"
        },
        "servers": [
          {
            "url": "https://simple-api.com",
            "description": "production"
          }
        ],
        "paths": []
      }
      """

      %Specification{content: _} = json |> FileReader.load_into_spec(:json)
    end

    test "reads a YAML file" do
      yaml = """
      openapi: 3.0.3
      info:
        title: simple api
        version: 1.0
        license:
          name: MIT
        description: A simple OpenAPI
      servers:
        - url: https://simple-api.com
          description: production api
      paths: []
      """

      %Specification{content: _} = yaml |> FileReader.load_into_spec(:yaml)
    end
  end
end
