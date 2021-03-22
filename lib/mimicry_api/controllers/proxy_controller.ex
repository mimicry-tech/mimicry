defmodule MimicryApi.ProxyController do
  use MimicryApi, :controller

  alias Mimicry.MockServerSupervisor

  import MimicryApi.Response, only: [respond_with_mimicry: 3]

  def show(conn = %Plug.Conn{}, params) do
    case conn |> get_req_header("x-mimicry-host") do
      # NOTE: we're taking the first occurence of the header value
      [host | _hosts] ->
        case MockServerSupervisor.find_server(%{host: host}) do
          {:ok, pid} ->
            response = conn |> respond_with_mimicry(pid, params)
            conn |> json(response)

          {:error, nil} ->
            conn |> put_status(:not_found) |> json(%{error: "No such API available!"})
        end

      [] ->
        conn
        |> json(%{
          message: ~s(Use "X-Mimicry-Host" HTTP header to direct traffic to a registered API)
        })
    end
  end
end
