defmodule Mimicry.MockApi do
  @moduledoc """
  contains functions for pretending to be a functional API based on a spec
  """
  require Logger

  @allowed_param_characters "[a-zA-Z0-9\_\-]*"
  @mimicry_not_found {"x-mimicry-path-not-found-in-specification", "1"}

  @doc """
  main entry point for responses.

  Essentially tries to infer the path used and respond with an example from the spec
  """
  @spec respond(Plug.Conn.t(), map()) :: map()
  def respond(_conn = %Plug.Conn{method: method, request_path: request_path}, spec) do
    paths = spec |> paths_from_spec()

    path =
      paths
      |> Enum.filter(fn {_path, regex_path} ->
        regex_path |> Regex.match?(request_path)
      end)
      |> case do
        [] -> :not_found
        [{path, _}] -> path
      end

    if path == :not_found do
      %{status: 404, headers: [@mimicry_not_found], body: %{}}
    else
      spec |> respond_with_spec(method, path)
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

  defp respond_with_spec(%{"paths" => paths}, method, path) do
    Logger.info(paths)

    %{
      status: :im_a_teapot,
      body: %{existing: true, path_called: paths[path], method: method},
      headers: [{"x-mimicry-found", path}, {"x-mimicry-method", method}]
    }
  end
end
