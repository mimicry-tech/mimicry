defmodule MimicryApi.ProxyController do
  use MimicryApi, :controller

  def show(conn, _params) do
    conn |> json(%{message: "To be implemented"})
  end
end
