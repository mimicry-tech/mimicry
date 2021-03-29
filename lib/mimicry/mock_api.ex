defmodule Mimicry.MockApi do
  @moduledoc """
  contains functions for pretending to be a functional API based on a spec
  """
  require Logger

  @doc """
  main entry point for responses.

  Essentially tries to infer the path used and respond with an example
  """
  @spec respond(Plug.Conn.t(), map()) :: map()
  def respond(conn = %Plug.Conn{method: method, request_path: path}, spec) do
    Logger.info(spec)
    %{status: 200, headers: [], body: %{}}
  end
end
