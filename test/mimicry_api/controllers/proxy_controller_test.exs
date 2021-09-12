defmodule MimicryApi.ProxyControllerTest do
  use MimicryApi.ConnCase
  use Mimicry.MockServerCase

  @tag server: "simple.yaml"
  test "GET /", %{conn: conn} do
    conn = conn |> get("/")

    assert json_response(conn, :ok)

    assert %{"message" => message} = conn |> json_response(:ok)
    assert message =~ "X-Mimicry-Host"
    assert [Mimicry.version()] == conn |> get_resp_header("x-mimicry-version")
  end

  test "GET / shows available hosts to pass", %{conn: conn} do
    conn = conn |> get("/")
    assert %{"available_hosts" => hosts} = conn |> json_response(:ok)
    assert hosts == []
  end

  @tag server: "simple.yaml"
  test "GET / shows available hosts when specs are running", %{conn: conn} do
    conn = conn |> get("/")

    assert %{
             "available_hosts" => [
               %{"url" => url, "title" => title, "version" => version}
             ]
           } = conn |> json_response(:ok)

    assert url == "https://simple-api.testing.com"
    assert title == "Test YAML"
    assert version == "1.0"
  end

  describe "when using \"x-mimicry-host\"" do
    @fake_host "https://foo.bar.com"

    # see fixtures / specs / simple.yaml
    @existing_host "https://simple-api.testing.com"

    @tag server: "simple.yaml"
    test "GET / with \"#{@fake_host}\"", %{conn: conn} do
      conn = conn |> put_req_header("x-mimicry-host", @fake_host) |> get("/")

      assert %{"message" => message} = json_response(conn, :not_found)
      assert message =~ "No such API available!"

      assert ["1"] = conn |> get_resp_header("x-mimicry-specification-not-found")
    end

    @tag server: "simple.yaml"
    test "GET / with \"#{@existing_host}\"", %{conn: conn} do
      conn = conn |> put_req_header("x-mimicry-host", @existing_host) |> get("/")
      assert %{"message" => _message} = conn |> json_response(:ok)
    end

    @tag server: "simple.yaml"
    test "GET / with a specific example in mind", %{conn: conn} do
      conn =
        conn
        |> put_req_header("x-mimicry-host", @existing_host)
        |> put_req_header("x-mimicry-example", "simple-reference")
        |> get("/")

      assert %{"message" => message} = conn |> json_response(:ok)
      assert message == "foobar"
    end

    @tag server: "simple.yaml"
    @tag :focus
    test "GET / with an expected 404", %{conn: conn} do
      conn =
        conn
        |> put_req_header("x-mimicry-host", @existing_host)
        |> put_req_header("x-mimicry-expect-status", "404")
        |> get("/")

      %{"code" => code} = conn |> json_response(:not_found)

      assert code == 42
    end
  end
end
