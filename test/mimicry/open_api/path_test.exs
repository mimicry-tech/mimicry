defmodule Mimicry.OpenAPI.PathTest do
  use ExUnit.Case
  use Mimicry.OpenAPISpecificationCase

  alias Mimicry.OpenAPI.{Path, Response}

  describe "extract_response/5" do
    @tag specification: "simple.yaml"
    test "finds a path in a given spec", %{specification: spec} do
      {:ok, %Response{schema: _schema, examples: _examples}} =
        spec |> Path.extract_response("get", "/")
    end

    @tag specification: "simple.yaml"
    test "errors if path cannot be found", %{specification: spec} do
      {:error, :not_found} =
        spec |> Path.extract_response("post", "/products/{productId}", "400", "application/xml")
    end

    @tag specification: "products-with-examples.yaml"
    test "finds a matching path", %{specification: spec} do
      {:ok, %Response{}} = spec |> Path.extract_response("get", "/products/foobar")
    end

    @tag specification: "products-with-examples.yaml"
    test "finds a matching example for the ", %{specification: spec} do
      {:ok, %Response{}} = spec |> Path.extract_response("get", "/products/foobar")
    end
  end
end
