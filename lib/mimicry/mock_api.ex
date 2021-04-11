defmodule Mimicry.MockApi do
  @moduledoc """
  contains functions for pretending to be a functional API based on a spec
  """
  require Logger

  alias Mimicry.MockRepo

  @allowed_param_characters "[a-zA-Z0-9\_\-]*"

  @doc """
  main entry point for responses.

  Essentially tries to infer the path used and respond with an example from the spec
  """
  @spec respond(Plug.Conn.t(), keyword()) :: map()
  def respond(
        _conn = %Plug.Conn{method: method, request_path: request_path},
        state
      ) do
    %{spec: spec, entities: entities} = state |> Enum.into(%{})
    paths = spec |> paths_from_spec()

    path_from_specification =
      paths
      |> Enum.filter(fn {_path, regex_path} ->
        regex_path |> Regex.match?(request_path)
      end)
      |> case do
        [] -> :not_found
        [{found, _}] -> found
      end

    if path_from_specification == :not_found do
      %{
        status: :not_found,
        headers:
          [{"x-mimicry-path-not-in-specification", "1"}]
          |> default_headers(request_path, method),
        body: %{}
      }
    else
      spec |> respond_with_spec(method, path_from_specification, entities)
    end
  end

  defp paths_from_spec(_spec = %{"paths" => paths}) do
    {usable, non_usable} = paths |> Map.keys() |> make_regex()

    if length(non_usable) > 0 do
      Logger.warn("Could not create regexp for the following paths", paths: non_usable)
    end

    usable
  end

  defp make_regex(paths) do
    Enum.map(paths, fn path ->
      case compile_path(path) do
        {:ok, r_path} -> {path, r_path}
        {:error, _} -> {path, nil}
      end
    end)
    |> Enum.split_with(fn {_path, regexp} -> !is_nil(regexp) end)
  end

  defp compile_path(path) do
    # turns the "{x}" params into named parameters within the final regexp
    # e.g.
    # /products/{productId} -> /products/<productId>[A-Za-z0-9\-\_]*
    ~r/{[A-Za-z0-9\_\-]*}/
    |> Regex.replace(path, fn x ->
      path = ~r/(\{|\})/ |> Regex.replace(x, "")
      "(?<#{path}>#{@allowed_param_characters})"
    end)
    |> Regex.compile()
  end

  defp respond_with_spec(%{"paths" => paths}, method, path, entities) do
    paths[path]
    |> Map.get(method |> String.downcase())
    |> case do
      nil ->
        %{
          status: :method_not_allowed,
          body: %{},
          headers:
            [
              {"x-mimicry-unsupported-method", "1"}
            ]
            |> default_headers(path, method)
        }

      %{"responses" => %{"200" => %{"content" => %{"application/json" => %{"schema" => schema}}}}} ->
        schema |> Map.get("$ref", nil) |> respond_with_schema(path, method, entities)
    end
  end

  defp respond_with_schema(nil, path, method, _entities) do
    %{
      status: :ok,
      body: %{message: "reference in schema not found"},
      headers: default_headers(path, method)
    }
  end

  defp respond_with_schema(reference, path, method, entities) do
    case entities[reference] |> MockRepo.get(:random) do
      {:ok, entity} ->
        %{
          status: :ok,
          body: entity,
          headers: default_headers(path, method)
        }

      {:error, _error} ->
        %{
          status: :bad_request,
          body: %{message: "entity examples insufficient"},
          headers: default_headers(path, method)
        }
    end
  end

  defp default_headers(headers \\ [], path, method) do
    [
      {"x-mimicry-path", path},
      {"x-mimicry-method", method}
    ]
    |> Enum.concat(headers)
  end
end
