defmodule MimicryApi.Router do
  use MimicryApi, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", MimicryApi do
    get("/", ProxyController, :show)

    scope "/__mimicry" do
      get("/", ServerController, :index)
      post("/", ServerController, :create)
    end
  end
end
