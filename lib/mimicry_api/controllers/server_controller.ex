defmodule MimicryApi.ServerController do
  use MimicryApi, :controller

  alias Mimicry.MockServer

  def index(conn, _params) do
    conn |> json(%{servers: MockServer.list_servers()})
  end

  def create(_conn, _params) do
  end

  def delete(_conn, _params) do
  end
end
