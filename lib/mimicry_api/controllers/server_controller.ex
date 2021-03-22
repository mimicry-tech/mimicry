defmodule MimicryApi.ServerController do
  use MimicryApi, :controller

  alias Mimicry.MockServerSupervisor

  def index(conn, _params) do
    conn |> json(%{servers: MockServerSupervisor.list_servers()})
  end

  def create(_conn, _params) do
  end

  def delete(_conn, _params) do
  end
end
