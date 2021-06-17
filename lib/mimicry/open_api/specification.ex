defmodule Mimicry.OpenAPI.Specification do
  @moduledoc """
  Specification represents a single specification file (either YAML or JSON)
  """
  # @derive {Jason.Encoder, only: [:content]}
  defstruct [:title, :content, :version, :openapi_version, :servers, :path, supported: true]

  @doc """
  returns the representation of an unsupported specification
  """
  def unsupported do
    %__MODULE__{
      version: "0.0.0",
      title: "Unsupported API",
      content: "",
      openapi_version: "0.0.0",
      servers: [],
      supported: false
    }
  end
end

defimpl Jason.Encoder, for: Mimicry.OpenAPI.Specification do
  @doc """
  We use a custom implementation to avoid the "content" key when just deriving the :content key
  inside the Specification struct.
  """
  def encode(spec, opts) do
    spec |> Map.get(:content, %{}) |> Jason.Encode.map(opts)
  end
end
