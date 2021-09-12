defmodule Mimicry.MockAPITest do
  use ExUnit.Case
  use Mimicry.OpenAPISpecificationCase
  use MimicryApi.ConnCase
  alias Mimicry.MockAPI

  describe "respond/2" do
    @tag specification: "products-with-examples.yaml"
    test "will respond with a specific path", %{conn: conn, specification: spec} do
      %{status: "200", body: _, headers: _} = conn |> get("/products") |> MockAPI.respond(spec)
    end

    @tag specification: "products-with-examples.yaml"
    test "will pick a product from the examples by a matching identifier", %{
      conn: conn,
      specification: spec
    } do
      %{status: "200", body: product, headers: _} =
        conn |> get("/products/foobar") |> MockAPI.respond(spec)

      assert product == %{
               "productId" => "foobar",
               "dimension" => %{"depth" => 12, "height" => 23, "width" => 8},
               "name" => "CoolProduct"
             }
    end
  end
end
