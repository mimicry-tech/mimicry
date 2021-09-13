defmodule MimicryApi.ErrorsTest do
  use ExUnit.Case

  alias MimicryApi.Errors

  describe "make_errors_from_openapi_validation/2" do
    test "will transform a list of tuples" do
      tuples = [{"foobar", "#"}, {"barfoo", "#baz"}]

      assert Errors.make_errors_from_openapi_validation(tuples) == [
               %{"#" => "foobar"},
               %{"#baz" => "barfoo"}
             ]
    end
  end
end
