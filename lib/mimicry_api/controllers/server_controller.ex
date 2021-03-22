defmodule MimicryApi.ServerController do
  use MimicryApi, :controller

  alias Mimicry.MockServerSupervisor

  def index(conn, _params) do
    conn |> json(%{servers: MockServerSupervisor.list_servers()})
  end

  def create(conn, %{"spec" => spec}) do
    case MockServerSupervisor.create_server(spec) do
      {:ok, %{id: id, spec: spec}} ->
        conn
        |> put_resp_header("x-mimicry-server-id", id |> to_string())
        |> json(spec)

      _ ->
        # TODO: weird fallback  remove
        conn |> create(%{})
    end
  end

  def create(conn, _) do
    conn
    |> put_status(:bad_request)
    |> json(%{message: "Can't do nothing with this, did you pass a spec?"})
  end

  def delete(conn, %{"id" => id}) do
    case MockServerSupervisor.delete_server(id) do
      [] ->
        conn |> put_status(:not_found) |> json(%{message: "Not found"})

      %{id: _, spec: _} = spec ->
        conn |> json(spec)

      _ ->
        conn |> put_status(:bad_request) |> json(%{message: "something went wrong"})
    end
  end
end
