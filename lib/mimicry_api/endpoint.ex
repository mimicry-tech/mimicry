defmodule MimicryApi.Endpoint do
  use Phoenix.Endpoint, otp_app: :mimicry

  if code_reloading? do
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(MimicryApi.Router)
end
