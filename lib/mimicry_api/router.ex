defmodule MimicryApi.Router do
  use MimicryApi, :router

  pipeline :api do
    plug(:accepts, ["json"])

    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  scope "/", MimicryApi do
    get("/", VersionController, :show)
  end
end
