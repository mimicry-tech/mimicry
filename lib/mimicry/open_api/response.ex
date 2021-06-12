defmodule Mimicry.OpenAPI.Response do
  @moduledoc """
  A struct to represent a potential response based on the `Mimicry.OpenAPI.Specification` powering the `MockServer`.
  """
  defstruct [:content_type, :schema, :description, examples: %{}, status: 200]
end
