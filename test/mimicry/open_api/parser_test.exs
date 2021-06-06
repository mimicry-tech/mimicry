defmodule Mimicry.OpenAPI.ParserTest do
  use ExUnit.Case

  alias Mimicry.OpenAPI.{
    Example,
    Parser,
    Specification
  }

  test "example/1" do
    yaml = """
    components:
      examples:
        my_example:
          summary: An example example
          value: '{"message": "example"}'
    """

    specification = %Specification{
      contents: yaml,
      extension: :yaml
    }

    {:ok, %Example{summary: summary, value: value}} =
      specification |> Parser.example("my_example")

    assert summary == "An example example"
    assert value == ~s({"message": "example"})
  end

  test "example/1 with embedded object" do
    yaml = """
    components:
      examples:
        my_example:
          summary: An example example
          value:
            message: example
    """

    specification = %Specification{
      contents: yaml,
      extension: :yaml
    }

    {:ok, %Example{summary: summary, value: value}} =
      specification |> Parser.example("my_example")

    assert summary == "An example example"
    assert value == %{"message" => "example"}
  end
end
