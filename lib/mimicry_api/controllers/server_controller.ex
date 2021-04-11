defmodule MimicryApi.ServerController do
  use MimicryApi, :controller

  alias Mimicry.{MockServer, MockServerList}

  def index(conn, _params) do
    conn |> json(%{servers: MockServerList.list_servers()})
  end

  def create(conn, %{"spec" => spec}) do
    {:ok, pid} = MockServerList.create_server(spec)

    {:ok, %{spec: spec, id: id}} = pid |> MockServer.get_details()

    conn
    |> put_resp_header("x-mimicry-server-id", id |> to_string())
    |> json(spec)
  end

  def create(conn, _) do
    conn
    |> put_status(:bad_request)
    |> json(%{message: "Can't do nothing with this, did you pass a spec?"})
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
        conn |> json(%{message: "Missing header: \"X-Mimicry-Host\""}) |> put_status(:bad_request)
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
