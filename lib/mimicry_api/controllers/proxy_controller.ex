defmodule MimicryApi.ProxyController do
  use MimicryApi, :controller

  alias Mimicry.MockServerList

  import MimicryApi.Response, only: [respond_with_mimicry: 3]

  def show(conn = %Plug.Conn{}, params) do
    case conn |> get_req_header("x-mimicry-host") do
      # NOTE: we're taking the first occurence of the header value
      [host | _hosts] ->
        case host |> MockServerList.find_server() do
          {:ok, pid} ->
            conn |> respond_with_mimicry(pid, params) |> destructure_response(conn)

          {:error, :not_found} ->
            conn
            |> put_status(:not_found)
            |> put_resp_header("x-mimicry-specification-not-found", "1")
            |> json(%{message: "No such API available!"})
        end

      [] ->
        conn
        |> json(%{
          message: ~s(Use "X-Mimicry-Host" HTTP header to direct traffic to a registered API)
        })
    end
  end

  defp destructure_response(%{body: body, headers: headers, status: status}, conn = %Plug.Conn{}) do
    conn
    |> clean_default_headers()
    |> merge_resp_headers(headers)
    |> put_status(status)
    |> json(body)
  end

  defp clean_default_headers(conn = %Plug.Conn{}) do
    conn
    |> delete_resp_header("content-type")
    |> delete_resp_header("cache-control")
    |> put_resp_header("server", "Mimicry")
  end
end
