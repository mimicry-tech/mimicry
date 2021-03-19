defmodule MimicryApi.Router do
  use MimicryApi, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", MimicryApi do
    scope "/__mimicry" do
      get("/version", VersionController, :show)
      get("/servers", ServerController, :index)
    end
  end
end
