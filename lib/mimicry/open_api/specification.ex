defmodule Mimicry.OpenAPI.Specification do
  @moduledoc """
  Specification represents a single specification file (either YAML or JSON)
  """
  @derive {Jason.Encoder, only: [:content]}
  defstruct [:title, :content, :version, :openapi_version, :servers]

  @doc """
  returns the representation of an unsupported specification
  """
  def unsupported do
    %__MODULE__{
      version: "0.0.0",
      title: "Unsupported API",
      content: "",
      openapi_version: "3.0.0",
      servers: []
    }
  end
end
