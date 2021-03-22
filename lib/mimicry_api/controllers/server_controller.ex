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

  def delete(_conn, _params) do
  end
end
