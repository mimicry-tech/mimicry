defmodule MimicryApi.ServerControllerTest do
  use MimicryApi.ConnCase

  test "GET /", %{conn: conn} do
    conn = conn |> get(Routes.server_path(conn, :index))
    assert %{"servers" => servers} = conn |> json_response(:ok)

    assert length(servers) > 1

    conn = conn |> get("/__mimicry/extra-params")
    assert _ = conn |> json_response(:im_a_teapot)
  end

  test "GET /spec", %{conn: conn} do
    conn = conn |> get(Routes.server_path(conn, :spec))
    assert %{"message" => message} = conn |> json_response(:bad_request)
    assert message =~ "Missing header"
  end

  test "POST /", %{conn: conn} do
    conn = conn |> post(Routes.server_path(conn, :create, %{}))
    assert %{"message" => message} = conn |> json_response(:bad_request)
    assert message =~ "Missing"

    conn = conn |> post(Routes.server_path(conn, :create, %{"spec" => "foobar"}))

    assert %{"message" => message} = conn |> json_response(:bad_request)
    assert message =~ "Invalid"

    spec = %{
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

  test "DELETE /:id", %{conn: conn} do
    conn = conn |> delete(Routes.server_path(conn, :delete, "foobar"))
    assert _ = conn |> json_response(:not_found)

    spec = %{
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
