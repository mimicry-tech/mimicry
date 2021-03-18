defmodule MimicryApi do
  @moduledoc """
  The API module containing all the things related to the API boundary of Mimicry
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: MimicryApi

      import Plug.Conn

      alias MimicryApi.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
