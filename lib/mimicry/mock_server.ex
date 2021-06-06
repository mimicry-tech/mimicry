defmodule Mimicry.MockServer do
  @moduledoc """
  `MockServer` realizes a single API server pretending to be some API based on a given OpenAPIv3 specification.
  """
  use GenServer
  require Logger

  alias Mimicry.{MockApi, MockRepo}
  alias Mimicry.OpenAPI.Specification

  @doc """
  gets the internal state of a mock server
  """
  def get_details(pid) do
    pid |> GenServer.call(:details)
  end

  def request(pid, conn = %Plug.Conn{}, _params = %{}) do
    pid |> GenServer.call({:request, conn})
  end

  def child_spec(id, openapi_spec) do
    %{
      id: id,
      start: {__MODULE__, :start_link, [[spec: openapi_spec, id: id]]},
      type: :worker
    }
  end

  def start_link(state = [spec: _spec, id: id]) do
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
  def init(state) do
    entities = MockRepo.build_examples(state |> Keyword.get(:spec, %{}))
    {:ok, [{:entities, entities} | state]}
  end

  @impl true
  def handle_call({:route, _method}, _from, state) do
    {:reply, nil, state}
  end

  @impl true
  def handle_call(:details, _from, state) do
    details = state |> Keyword.take([:spec, :entities, :id]) |> Enum.into(%{})
    {:reply, {:ok, details}, state}
  end

  @impl true
  def handle_call({:request, conn = %Plug.Conn{}}, _from, state) do
    {:reply, conn |> MockApi.respond(state), state}
  end
end
