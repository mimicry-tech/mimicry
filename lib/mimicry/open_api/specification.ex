defmodule Mimicry.OpenAPI.Specification do
  @moduledoc """
  Specification represents a single specification file (either YAML or JSON)
  """
  defstruct [:original_file, :contents, :extension]
end
