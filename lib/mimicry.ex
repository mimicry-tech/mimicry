defmodule Mimicry do
  @moduledoc """
  Documentation for `Mimicry`.
  """

  def code_name, do: "Ditto"

  def version do
    Application.spec(:mimicry, :vsn)
    |> to_string()
  end
end
