defmodule MimicryApi.ResponseHeaders do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _options) do
    conn
    |> put_resp_header("x-mimicry-version", Mimicry.version())
    |> put_resp_header("x-mimicry-codename", Mimicry.code_name())
  end
end
