defmodule Mimicry.MockServer do
  @moduledoc """
  `MockServer` realizes a single API server pretending to be some API based on a given OpenAPIv3 specification.
  """
  use GenServer
  require Logger

  alias Mimicry.MockAPI
  alias Mimicry.OpenAPI.Specification

  @doc """
  gets the internal state of a mock server
  """
  @spec get_details(pid()) :: map()
  def get_details(pid) do
    pid |> GenServer.call(:details)
  end

  @doc """
  Makes a request against a mock server process, returning a map with the details for the
  actual response
  """
  @spec request(pid, Plug.Conn.t(), map()) :: map()
  def request(pid, conn = %Plug.Conn{}, _params = %{}) do
    pid |> GenServer.call({:request, conn})
  end

  @doc """
  Creates a child spec for the `Mimicry.MockServerList`
  """
  @spec child_spec(atom(), Specification.t(), String.t()) :: map()
  def child_spec(id, openapi_spec, path \\ "") do
    %{
      id: id,
      start: {__MODULE__, :start_link, [[spec: openapi_spec, id: id, path: path]]},
      type: :worker
    }
  end

  def update_server_specification(pid, spec = %Specification{}) do
    pid |> GenServer.call({:update_spec, spec})
  end

  def start_link(state = [spec: _spec, id: id, path: _path]) do
    GenServer.start_link(__MODULE__, state, name: id)
  end

  def create_id(%Specification{title: title, version: version}) do
    :md5
    |> :crypto.hash("#{title}-#{version}")
    |> Base.encode16(case: :lower)
    |> String.to_atom()
  end

  def create_id(_), do: raise(~s(Missing "title" + "version"))

  ## Callbacks

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:route, _method}, _from, state) do
    {:reply, nil, state}
  end

  @impl true
  def handle_call(:details, _from, state) do
    details = state |> Keyword.take([:spec, :id]) |> Enum.into(%{})
    {:reply, {:ok, details}, state}
  end

  @impl true
  def handle_call({:request, conn = %Plug.Conn{}}, _from, state) do
    spec = state |> Keyword.get(:spec, nil)
    {:reply, conn |> MockAPI.respond(spec), state}
  end

  @impl true
  def handle_call({:update_spec, specification}, _from, state) do
    {:reply, :ok, state |> Keyword.merge(spec: specification)}
  end
end
