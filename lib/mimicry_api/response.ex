defmodule MimicryApi.Response do
  @moduledoc """
  Represents a fake response from mimicry, essentially providing functions for passing around
  the original parameters to a request to a fake MockServer
  """

  alias Mimicry.MockServer

  @spec respond_with_mimicry(Plug.Conn.t(), pid(), map()) :: map()
  def respond_with_mimicry(conn = %Plug.Conn{}, pid, params) do
    pid |> MockServer.request(conn, params)
  end
end
