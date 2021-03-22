defmodule Mimicry.MockServer do
  @moduledoc """
  `MockServer` realizes a single API server pretending to be some API based on a given OpenAPIv3 specification.
  """
  use GenServer

  def get_details(pid) do
    pid |> GenServer.call(:details)
  end

  def child_spec(id, openapi_spec) do
    %{
      id: id,
      start: {__MODULE__, :start_link, [[spec: openapi_spec, id: id]]},
      type: :worker
    }
  end

  def start_link([spec: _spec, id: id] = state) do
    GenServer.start_link(__MODULE__, state, name: id)
  end

  def create_id(%{"info" => %{"title" => title, "version" => version}}) do
    :md5
    |> :crypto.hash("#{title}-#{version}")
    |> Base.encode16(case: :lower)
    |> String.to_atom()
  end

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
    {:reply, details, state}
  end
end
