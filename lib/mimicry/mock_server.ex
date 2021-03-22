defmodule Mimicry.MockServer do
  @moduledoc """
  `MockServer` realizes a single API server pretending to be some API based on a given OpenAPIv3 specification.
  """
  use GenServer

  def call_route(params) do
    GenServer.call(__MODULE__, :call_route, params)
  end

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call(:call_route, _from, state) do
    {:reply, nil, state}
  end
end
