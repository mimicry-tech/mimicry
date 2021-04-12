defmodule Mimicry.MockApi do
  @moduledoc """
  contains functions for pretending to be a functional API based on a spec
  """
  require Logger

  alias Mimicry.MockRepo

  @allowed_param_characters "\\S"

  @doc """
  main entry point for responses.

  Essentially tries to infer the path used and respond with an example from the spec
  """
  @spec respond(Plug.Conn.t(), keyword()) :: map()
  def respond(
        _conn = %Plug.Conn{method: method, request_path: request_path, req_headers: req_headers},
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
        [{found, _} | _] -> found
        [] -> :not_found
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
      code =
        req_headers
        |> Enum.find(fn {header, _} -> header == "x-mimicry-expected-response" end)
        |> case do
          nil -> "default"
          {"x-mimicry-expected-response", code} -> code
        end

      spec
      |> respond_with_spec(method, path_from_specification, entities, %{
        response: code
      })
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
    r_path =
      ~r/{[A-Za-z0-9\_\-]*}/
      |> Regex.replace(path, fn x ->
        path = ~r/(\{|\})/ |> Regex.replace(x, "")
        "(?<#{path}>#{@allowed_param_characters})"
      end)

    "#{r_path}$" |> Regex.compile()
  end

  defp respond_with_spec(
         %{"paths" => paths},
         method,
         path,
         entities,
         %{response: response} = _expectations
       ) do
    paths[path]
    # TODO: there is more content types and responses
    |> get_in([
      method |> String.downcase(),
      "responses",
      # TODO: X-Mimicry-Expected-Response-Code
      response,
      "content",
      # TODO: react to Accept header / or the first you find in case accept is */*
      "application/json",
      "schema"
    ])
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

      %{"$ref" => reference} ->
        reference |> respond_with_single(path, method, entities)

      %{"allOf" => [%{"$ref" => reference} | _]} ->
        reference |> respond_with_multiple(path, method, entities)

      match ->
        Logger.warn("Non-implemented function!", code: match)

        %{
          status: :not_implemented,
          body: %{message: "Not yet implemented"},
          headers: [{"x-mimicry-not-implemented", "1"}] |> default_headers(path, method)
        }
    end
  end

  defp respond_with_single(reference, path, method, entities) do
    case entities |> Map.get(reference, []) |> MockRepo.get(:random) do
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

  defp respond_with_multiple(reference, path, method, entities) do
    case entities |> Map.get(reference, []) |> MockRepo.get(:random) do
      {:ok, entity} ->
        %{
          status: :ok,
          body: [entity],
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
