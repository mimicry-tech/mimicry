defmodule MimicryApi.ServerController do
  use MimicryApi, :controller

  alias Mimicry.{MockServer, MockServerList}
  alias Mimicry.OpenAPI.Specification

  def index(conn, _params) do
    conn |> json(%{servers: MockServerList.list_servers()})
  end

  def create(conn, %{"spec" => spec}) do
    case spec |> MockServerList.create_server() do
      {:ok, pid} ->
        {:ok, %{spec: spec, id: id}} = pid |> MockServer.get_details()

        conn
        |> put_resp_header("x-mimicry-server-id", id |> to_string())
        |> json(spec)

      {:error, :invalid_specification} ->
        conn |> put_status(:bad_request) |> json(%{message: "Invalid specification!"})
    end
  end

  def create(conn, _) do
    conn
    |> put_status(:bad_request)
    |> json(%{message: "Missing 'spec' property!"})
  end

  def spec(conn = %Plug.Conn{req_headers: headers}, _params) do
    case headers |> Enum.find(nil, fn {header, _} -> header == "x-mimicry-host" end) do
      {_, host} ->
        case MockServerList.find_server(host) do
          {:ok, server} ->
            {:ok, %{spec: spec}} = MockServer.get_details(server)
            conn |> json(spec)

          _ ->
            conn |> put_status(:not_found)
        end

      nil ->
        conn |> put_status(:bad_request) |> json(%{message: "Missing header: \"X-Mimicry-Host\""})
    end
  end

  def delete(conn, %{"id" => id}) do
    case MockServerList.delete_server(id) do
      [%{spec: spec, id: _id}] ->
        conn |> json(spec)

      [] ->
        conn |> put_status(:not_found) |> json(%{message: "Not found"})
    end
  end

  def show(conn, _params),
    do: conn |> put_status(:im_a_teapot) |> json(%{message: "Nothing to see here"})
end
