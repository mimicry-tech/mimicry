defmodule MimicryApi.ServerControllerTest do
  use MimicryApi.ConnCase
  use Mimicry.MockServerCase

  import Fixtures

  @tag server: "simple.yaml"
  test "GET /__mimicry/", %{conn: conn} do
    conn = conn |> get(Routes.server_path(conn, :index))
    assert %{"servers" => servers} = conn |> json_response(:ok)

    assert length(servers) == 1

    conn = conn |> get("/__mimicry/extra-params")
    assert _ = conn |> json_response(:im_a_teapot)
  end

  @tag server: "simple.yaml"
  test "GET /spec", %{conn: conn} do
    conn = conn |> get(Routes.server_path(conn, :spec))
    assert %{"message" => message} = conn |> json_response(:bad_request)
    assert message =~ "Missing header"
  end

  describe "POST /" do
    test "when the payload is not a spec", %{conn: conn} do
      conn = conn |> post(Routes.server_path(conn, :create, %{}))
      assert %{"message" => message} = conn |> json_response(:unprocessable_entity)
      assert message =~ "Pass the raw spec"

      conn = conn |> post(Routes.server_path(conn, :create, %{yaml: "foobar"}))

      assert %{"message" => message} = conn |> json_response(:bad_request)
      assert message =~ "Invalid"
    end

    test "when the payload is a YAML spec", %{conn: conn} do
      spec = load_fixture("simple.yaml")

      conn =
        conn
        |> post(
          Routes.server_path(conn, :create, %{
            "yaml" => spec
          })
        )

      assert _ = conn |> json_response(:ok)
      assert [_server_id] = conn |> get_resp_header("x-mimicry-server-id")
    end

    test "when the payload is a JSON spec", %{conn: conn} do
      spec = load_fixture("simple.json")

      conn =
        conn
        |> post(
          Routes.server_path(conn, :create, %{
            "json" => spec
          })
        )

      assert _ = conn |> json_response(:ok)
      assert [_server_id] = conn |> get_resp_header("x-mimicry-server-id")
    end

    test "when the payload is an incomplete YAML spec", %{conn: conn} do
      spec = "openapi: 3.0.0"

      conn =
        conn
        |> post(Routes.server_path(conn, :create, %{yaml: spec}))

      assert %{"message" => message, "errors" => errors} = conn |> json_response(:bad_request)
      assert message =~ "Invalid"
      assert errors |> length() > 0
    end

    test "when the payload is an incomplete JSON spec", %{conn: conn} do
      spec = '''
        { "openapi": "3.0.0" }
      '''

      conn =
        conn
        |> post(Routes.server_path(conn, :create, %{json: spec}))

      assert %{"message" => message, "errors" => errors} = conn |> json_response(:bad_request)
      assert message =~ "Invalid"
      assert errors |> length() > 0
    end

    test "when the payload is YAML and contains integers as response codes", %{conn: conn} do
      spec = load_fixture("simple-with-broken-integer.yaml")

      conn =
        conn
        |> post(
          Routes.server_path(conn, :create, %{
            "yaml" => spec
          })
        )

      assert %{"message" => message} = conn |> json_response(:unprocessable_entity)

      assert message =~
               "Could not parse specification"
    end
  end

  describe "DELETE /:id" do
    test "when deleting a non existing server", %{conn: conn} do
      conn = conn |> delete(Routes.server_path(conn, :delete, "foobar"))
      assert _ = conn |> json_response(:not_found)
    end

    test "when deleting an existing server", %{conn: conn} do
      spec = load_fixture("simple.yaml")

      conn = conn |> post(Routes.server_path(conn, :create, %{"yaml" => spec}))
      assert _ = conn |> json_response(:ok)
      assert [server_id] = conn |> get_resp_header("x-mimicry-server-id")

      conn = conn |> delete(Routes.server_path(conn, :delete, server_id))
      assert response = conn |> json_response(:ok)

      assert response == YamlElixir.read_from_string!(spec)
    end
  end
end
