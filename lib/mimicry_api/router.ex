defmodule MimicryApi.Router do
  use MimicryApi, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", MimicryApi do
    scope "/__mimicry" do
      get("/", ServerController, :index)
      post("/", ServerController, :create)
      delete("/:id", ServerController, :delete)
    end

    get("/*path", ProxyController, :show)
  end
end
