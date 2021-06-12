defmodule MimicryApi.ServerController do
  use MimicryApi, :controller

  alias Mimicry.{MockServer, MockServerList}
  alias Mimicry.OpenAPI.Parser, as: SpecParser

  def index(conn, _params) do
    conn |> json(%{servers: MockServerList.list_servers()})
  end

  def create(conn, %{"spec" => definition}) do
    definition |> SpecParser.build_specification()

    with spec <- definition |> SpecParser.build_specification(),
         {:ok, pid} <- MockServerList.create_server(spec),
         {:ok, %{id: id} = response} = pid |> MockServer.get_details() do
      conn
      |> put_resp_header("x-mimicry-server-id", id |> to_string())
      |> json(response)
    else
      {:error, :invalid_spec} ->
        conn |> put_status(:bad_request) |> json(%{message: "Invalid specification!"})

      {:error, _} ->
        conn |> put_status(:bad_request) |> json(%{message: "Invalid JSON"})
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
