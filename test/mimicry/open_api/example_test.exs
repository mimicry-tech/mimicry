defmodule Mimicry.OpenAPI.ExampleTest do
  use ExUnit.Case
  use Mimicry.OpenAPISpecificationCase

  alias Mimicry.OpenAPI.{Example, Response}

  @examples %{
    "foobar" => %{
      "summary" => "Some words on foobar",
      "value" => %{"foo" => "bar"}
    },
    "bazbaz_reference_combined" => %{
      "$ref" => "simple-message-example",
      "summary" => "Another example, as a reference, but with overrides"
    },
    "full_reference" => %{
      "$ref" => "simple-message-example"
    }
  }

  describe "choose/3" do
    @tag specification: "simple.yaml"
    test "will pick an example from the response", %{specification: spec} do
      response = %Response{examples: @examples}

      {:ok, example} = response |> Example.choose("foobar", spec)
      assert example == @examples["foobar"]
    end

    @tag specification: "simple.yaml"
    test "will pick an example from the references in the spec", %{specification: spec} do
      response = %Response{examples: @examples}
      {:ok, example} = response |> Example.choose("full_reference", spec)

      assert example == %{
               "summary" => "a simple message",
               "value" => %{"message" => "foobar"}
             }
    end

    @tag specification: "simple.yaml"
    test "will pick an example from the reference and merge", %{specification: spec} do
      response = %Response{examples: @examples}
      {:ok, example} = response |> Example.choose("bazbaz_reference_combined", spec)

      assert example == %{
               "summary" => "Another example, as a reference, but with overrides",
               "value" => %{"message" => "foobar"}
             }
    end

    @tag specification: "simple.yaml"
    test "will return an error if there is not examples", %{specification: spec} do
      response = %Response{examples: @examples}

      {:error, :not_found} = response |> Example.choose("non_existing", spec)
    end

    @tag specification: "simple.yaml"
    test "will return a random example", %{specification: spec} do
      response = %Response{examples: @examples}
      {:ok, %{"value" => _}} = response |> Example.choose(:random, spec)
    end

    test "will return an error if no examples are defined" do
      response = %Response{examples: %{}}

      {:error, :no_examples} = response |> Example.choose(:random, %{})
    end
  end
end
