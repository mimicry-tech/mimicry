defmodule Mimicry.OpenAPI.Path do
  @moduledoc """
  contains functions to extract paths from within a given `Mimicry.OpenAPI.Specification`
  """
  @allowed_param_characters "\\S*"

  alias Mimicry.OpenAPI.{Response, Specification}

  def extract_response(
        spec = %Specification{content: %{"paths" => paths}},
        method,
        path,
        code \\ "default",
        content_type \\ "application/json"
      ) do
    paths
    |> get_in([path, method |> String.downcase(), "responses", code])
    |> case do
      nil ->
        # Specific path not found -> try matching
        if path = paths |> lookup_matching_path(path, method, code) do
          extract_response(spec, method, path, code, content_type)
        else
          {:error, :not_found}
        end

      %{"content" => content, "description" => description} ->
        response =
          %Response{} =
          content
          |> build_response_from_content(content_type)
          |> Map.merge(%{
            description: description,
            content_type: content_type,
            status: pick_status(code)
          })

        {:ok, response}
    end
  end

  defp build_response_from_content(content, content_type) do
    content
    |> Map.get(content_type, %{})
    |> case do
      %{"schema" => schema, "examples" => examples} ->
        %Response{schema: schema, examples: examples}

      # NOTE: examples are optional
      %{"schema" => schema} ->
        %Response{schema: schema, examples: %{}}
    end
  end

  defp lookup_matching_path(available_paths, path, _method, _code) do
    {usable, _} = available_paths |> Map.keys() |> make_regex()

    usable
    |> Enum.filter(fn {_path, regex_path} ->
      regex_path |> Regex.match?(path)
    end)
    |> case do
      # Take the first matching path
      [{found, _} | _] -> found
      [] -> false
    end
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

  defp pick_status("default"), do: %Response{}.status
  defp pick_status(val), do: val
end
