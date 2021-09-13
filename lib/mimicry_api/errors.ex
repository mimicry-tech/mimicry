defmodule MimicryApi.Errors do
  @moduledoc """
  Provides functions for transforming errors from libs into something usable to the API
  """
  def make_errors_from_openapi_validation(errors) do
    errors |> Enum.map(fn {msg, path} -> %{path => msg} end)
  end
end
