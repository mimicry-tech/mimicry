defmodule Mimicry.MockAPI do
  @moduledoc """
  contains functions for pretending to be a functional API based on a spec
  """
  require Logger

  alias Mimicry.OpenAPI.{Example, Path, Response, Specification}
  import Plug.Conn, only: [get_req_header: 2]

  @doc """
  main entry point for responses.

  Essentially tries to infer the path used and respond with an example from the spec
  """
  @spec respond(Plug.Conn.t(), Specification.t() | nil) :: map()
  def respond(
        conn = %Plug.Conn{method: method, request_path: request_path},
        spec = %Specification{}
      ) do
    expected_code =
      conn
      |> get_req_header("x-mimicry-expect-status")
      |> List.first()
      # TODO: For JSON, all keys are strings, always
      |> ensure_numerical()
      |> fallback("default")

    expected_example =
      conn |> get_req_header("x-mimicry-example") |> List.first() |> fallback(:random)

    content_type =
      conn |> get_req_header("Accept") |> List.first() |> fallback("application/json")

    response =
      spec
      |> Path.extract_response(method, request_path, expected_code, content_type)

    case response do
      {:ok, response = %Response{}} ->
        example = response |> Example.choose(expected_example, spec)

        request_path |> respond_with(response, method, example)

      {:error, :not_found} ->
        %{
          status: :not_found,
          headers: default_headers(request_path, method),
          body: %{}
        }

      {:error, :no_examples} ->
        %{
          status: :not_implemented,
          headers: default_headers(request_path, method),
          body: %{}
        }
    end
  end

  def respond(%Plug.Conn{request_path: path, method: method}, nil) do
    %{status: :internal_error, headers: default_headers([], method, path), body: %{}}
  end

  defp default_headers(path, method, headers \\ []) do
    [
      {"x-mimicry-path", path},
      {"x-mimicry-method", method}
    ]
    |> Enum.concat(headers)
  end

  defp fallback(nil, fb), do: fb
  defp fallback(value, _), do: value

  defp respond_with(path, _, method, {:error, :no_examples}) do
    %{
      status: :not_implemented,
      headers: default_headers(path, method),
      body: %{
        error: "No examples for this response found"
      }
    }
  end

  defp respond_with(path, response, method, {:ok, %{"value" => value} = _example}) do
    headers = [
      {"x-mimicry-description", response.description},
      {"content-type", response.content_type}
    ]

    %{
      status: response.status,
      headers: default_headers(path, method, headers),
      body: value
    }
  end

  defp ensure_numerical(nil), do: nil

  defp ensure_numerical(maybe_number) do
    case Integer.parse(maybe_number) do
      :error -> nil
      {number, _} -> number
    end
  end
end
