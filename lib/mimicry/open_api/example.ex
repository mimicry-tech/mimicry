defmodule Mimicry.OpenAPI.Example do
  @moduledoc """
  Representation for a single example from a spec file
  """

  defstruct [:value, summary: ""]

  def build(%{"summary" => summary, "value" => value}) do
    %__MODULE__{summary: summary, value: value}
  end
end
