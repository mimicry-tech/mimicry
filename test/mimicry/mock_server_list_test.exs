defmodule Mimicry.MockServerListTest do
  use Mimicry.MockServerCase

  alias Mimicry.{MockServer, MockServerList}
  alias Mimicry.OpenAPI.Parser

  describe "find_server/1" do
    @tag server: "simple.yaml"
    test "looks up a mock server by it's host" do
      assert {:ok, _} = MockServerList.find_server("https://simple-api.testing.com")
    end

    @tag server: "simple.yaml"
    test "errors, when the host does not exist" do
      assert {:error, :not_found} = MockServerList.find_server("some-bogus-host.com")
    end
  end

  describe "list_servers/0" do
    @tag server: "simple.yaml"
    test "will list all the existing servers currently supervised" do
      # NOTE: this is the example server from the fixtures/specs
      assert [%{entities: %{}, id: _} | _] = MockServerList.list_servers()
    end
  end

  describe "create_server/0" do
    test "will not create a new supervised server without a proper info section" do
      assert {:error, :invalid_specification} = MockServerList.create_server(%{})
    end

    test "will start a new server based on the info section" do
      spec =
        %{"info" => %{"title" => "myApi", "version" => "1.0.0alpha"}, "servers" => []}
        |> Parser.build_specification()

      assert {:ok, _} = MockServerList.create_server(spec)
    end

    test "will not recreate the server" do
      spec =
        %{"info" => %{"title" => "myApi", "version" => "1.0.0alpha"}, "servers" => []}
        |> Parser.build_specification()

      {:ok, pid} = MockServerList.create_server(spec)
      assert {:ok, ^pid} = MockServerList.create_server(spec)
    end
  end

  describe "delete_server/1" do
    setup do
      definition = %{
        "info" => %{"title" => "myDeletableApi", "version" => "1.0.0alpha"},
        "servers" => []
      }

      spec = Parser.build_specification(definition)

      {:ok, pid} = MockServerList.create_server(spec)
      {:ok, %{id: id}} = pid |> MockServer.get_details()

      {:ok, %{id: id}}
    end

    @tag :focus
    test "will delete a server by it's id", %{id: id} do
      [%{id: ^id}] = id |> MockServerList.delete_server()
    end
  end
end
