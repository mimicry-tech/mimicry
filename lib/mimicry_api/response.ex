defmodule MimicryApi.Response do
  @moduledoc """
  Represents a fake response from mimicry, essentially providing functions for passing around
  the original parameters to a request to a fake MockServer
  """

  @spec respond_with_mimicry(Plug.Conn.t(), pid(), map()) :: map()
  def respond_with_mimicry(_conn = %Plug.Conn{}, pid, _params) do
    pid |> :sys.get_state() |> Keyword.get(:spec, %{})
  end
end
