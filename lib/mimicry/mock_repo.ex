defmodule Mimicry.MockRepo do
  @moduledoc """
  The MockRepo can be used for fetch entities from the example section within `components -> schemas` of the spec given
  """

  require Logger

  @doc """
  extracts examples for the list of schemas given with the speicifcation, creating a simple lookup table
  for the entities by their name
  """
  @spec build_examples(map()) :: map()
  def build_examples(%{"components" => %{"schemas" => entities}} = _openapi_spec) do
    entities
    |> Enum.into(%{}, fn {entity_name, %{"x-examples" => examples}} ->
      {"/#components/schemas/#{entity_name}", examples}
    end)
  end

  def build_examples(_), do: %{}

  @doc """
  For a set of entities, retrieve one, either by a given ID or at random
  """
  @spec get(list(), keyword() | :random) ::
          {:ok, any()} | {:error, :not_found} | {:error, :bad_param}
  def get(entities, param \\ :random) do
    case param do
      :random ->
        entity = entities |> Enum.shuffle() |> hd()
        {:ok, entity}

      {name, given_value} ->
        case(entities |> Enum.find(fn {key, val} -> key == name && val == given_value end)) do
          nil -> {:error, :not_found}
          entity -> {:ok, entity}
        end

      _ ->
        Logger.warn("param given to MockRepo.get/2 must be :random or a keyword list")
        {:error, :bad_param}
    end
  end
end
