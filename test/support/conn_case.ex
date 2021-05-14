defmodule MimicryApi.ConnCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest

      alias MimicryApi.Router.Helpers, as: Routes

      @endpoint MimicryApi.Endpoint
    end
  end

  setup _tags do
    %{conn: Phoenix.ConnTest.build_conn()}
  end
end
