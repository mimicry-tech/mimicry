defmodule MimicryApi.Router do
  use MimicryApi, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", MimicryApi do
    scope "/__mimicry" do
      get("/", ServerController, :index)
      post("/", ServerController, :create)
      get("/spec", ServerController, :spec)
      delete("/:id", ServerController, :delete)

      get("/*path", ServerController, :show)
    end

    get("/*path", ProxyController, :show)
    put("/*path", ProxyController, :show)
    post("/*path", ProxyController, :show)
    head("/*path", ProxyController, :show)
    trace("/*path", ProxyController, :show)
    patch("/*path", ProxyController, :show)
    options("/*path", ProxyController, :show)
  end
end
