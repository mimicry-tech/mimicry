defmodule MimicryApi.ProxyControllerTest do
  use MimicryApi.ConnCase

  test "GET /", %{conn: conn} do
    conn = conn |> get("/")

    assert json_response(conn, :ok)

    assert %{"message" => message} = conn |> json_response(:ok)
    assert message =~ "X-Mimicry-Host"
    assert [Mimicry.version()] == conn |> get_resp_header("x-mimicry-version")
  end

  describe "when using \"x-mimicry-host\"" do
    @fake_host "https://foo.bar.com"
    # see fixtures/specs/simple.yaml
    @existing_host "https://simple-api.testing.com"

    test "GET / with \"#{@fake_host}\"", %{conn: conn} do
      conn = conn |> put_req_header("x-mimicry-host", @fake_host) |> get("/")

      assert %{"message" => message} = json_response(conn, :not_found)
      assert message =~ "No such API available!"

      assert ["1"] = conn |> get_resp_header("x-mimicry-specification-not-found")
    end

    test "GET / with \"#{@existing_host}\"", %{conn: conn} do
      conn = conn |> put_req_header("x-mimicry-host", @existing_host) |> get("/")
      assert %{"message" => message} = conn |> json_response(:ok)

      assert message =~ "Simple message!"
    end
  end
end
