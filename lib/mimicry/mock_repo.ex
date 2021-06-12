defmodule Mimicry.MockRepo do
  @moduledoc """
  The MockRepo can be used for fetch entities from the example section within `components -> schemas` of the spec given
  """

  alias Mimicry.OpenAPI.Specification
  require Logger

  @doc """
  Given a speicification, find an example for a given reference
  """
  def example(spec = %Specification{content: content}, reference) do
  end

  @doc """
  For a set of entities, retrieve one, either by a given ID or at random
  """
  @spec get(list(), keyword() | :random) ::
          {:ok, any()} | {:error, :not_found} | {:error, :bad_param}
  def get(entities, param \\ :random)
  def get([], _param), do: {:error, :not_found}

  def get(entities, param) do
    case param do
      :random ->
        entity = entities |> Enum.shuffle() |> hd()
        {:ok, entity}

      {name, given_value} ->
        entities |> find_by_name_and_given_value(name, given_value)

      _ ->
        Logger.warn("param given to MockRepo.get/2 must be :random or a keyword list")
        {:error, :bad_param}
    end
  end

  defp find_by_name_and_given_value(entities, name, given_value) do
    # NOTE: not all data in the example are necessarily strings
    case entities |> Enum.find(fn {key, val} -> key == name && val == given_value end) do
      nil -> {:error, :not_found}
      entity -> {:ok, entity}
    end
  end
end
