defmodule Mimicry.OpenAPI.Example do
  @moduledoc """
  Contains functions for contructing payloads for a `Mimicry.OpenAPI.Response`
  """

  alias Mimicry.OpenAPI.{Response, Specification}

  @doc """
  chooses an example based on the defined examples for the response and the spec (for references)
  """
  @spec choose(Response.t(), String.t() | :random, Specification.t()) ::
          {:ok, map()} | {:error, :not_found} | {:error, :no_examples}
  def choose(
        response,
        reference_or_random,
        spec \\ Specification.unsupported()
      )

  def choose(%Response{examples: examples}, :random, _) when examples == %{},
    do: {:error, :no_examples}

  def choose(
        _response = %Response{examples: examples},
        :random,
        spec = %Specification{}
      ) do
    {key, _} = examples |> Enum.random()

    examples
    |> Map.get(key, nil)
    |> case do
      nil ->
        {:error, :not_found}

      %{"$ref" => ref} = example ->
        {:ok, ref |> lookup(spec) |> Map.merge(example) |> Map.delete("$ref")}

      %{"value" => _} = example ->
        {:ok, example}
    end
  end

  def choose(
        _response = %Response{examples: examples},
        reference,
        spec = %Specification{}
      ) do
    case examples |> Map.get(reference, nil) do
      nil ->
        {:error, :not_found}

      %{"$ref" => ref} = example ->
        {:ok, ref |> lookup(spec) |> Map.merge(example) |> Map.delete("$ref")}

      %{"value" => _} = example ->
        {:ok, example}
    end
  end

  defp lookup(
         reference,
         _spec = %Specification{content: %{"components" => %{"examples" => examples}}}
       ) do
    example_name = reference |> Path.split() |> List.last()

    examples
    |> Map.get(example_name, :not_found)
    |> case do
      :not_found -> %{}
      example -> example
    end
  end

  defp lookup(_, _), do: {:error, :not_found}
end
