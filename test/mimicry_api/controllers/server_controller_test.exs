defmodule MimicryApi.ServerControllerTest do
  use MimicryApi.ConnCase
  use Mimicry.MockServerCase

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
      assert %{"message" => message} = conn |> json_response(:bad_request)
      assert message =~ "Missing"

      conn = conn |> post(Routes.server_path(conn, :create, %{"spec" => %{"foobar" => "foo"}}))

      assert %{"message" => message} = conn |> json_response(:bad_request)
      assert message =~ "Invalid"
    end

    test "when the payload is a spec", %{conn: conn} do
      spec = %{
        "openapi" => "3.0.0",
        "info" => %{"title" => "myFreshNewApi", "version" => "1.0.0alpha"},
        "servers" => [
          %{"url" => "https://fresh-api.testing.com"}
        ],
        "paths" => [%{"/" => %{}}]
      }

      conn = conn |> post(Routes.server_path(conn, :create, %{"spec" => spec}))
      assert _ = conn |> json_response(:ok)
      assert [_server_id] = conn |> get_resp_header("x-mimicry-server-id")
    end
  end

  describe "DELETE /:id" do
    test "when deleting a non existing server", %{conn: conn} do
      conn = conn |> delete(Routes.server_path(conn, :delete, "foobar"))
      assert _ = conn |> json_response(:not_found)
    end

    test "when deleting an existing server", %{conn: conn} do
      spec = %{
        "openapi" => "3.0.0",
        "info" => %{"title" => "mySuperDeletableApi", "version" => "1.0.0alpha"},
        "paths" => [%{"/" => %{"get" => %{"responses" => %{"valid" => "spec"}}}}],
        "servers" => [
          %{"url" => "https://fresh-deletable-api.testing.com"}
        ]
      }

      conn = conn |> post(Routes.server_path(conn, :create, %{"spec" => spec}))
      assert _ = conn |> json_response(:ok)
      assert [server_id] = conn |> get_resp_header("x-mimicry-server-id")

      conn = conn |> delete(Routes.server_path(conn, :delete, server_id))
      assert response = conn |> json_response(:ok)

      assert response == spec
    end
  end
end
