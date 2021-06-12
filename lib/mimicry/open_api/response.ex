defmodule Mimicry.OpenAPI.Response do
  defstruct [:content_type, :schema, :description, examples: %{}, status: 200]
end
