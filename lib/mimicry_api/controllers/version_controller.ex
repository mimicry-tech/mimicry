defmodule MimicryApi.VersionController do
  use MimicryApi, :controller

  def show(conn, _params) do
    conn |> resp(200, "#{Mimicry.code_name()} / #{Mimicry.version()}")
  end
end
