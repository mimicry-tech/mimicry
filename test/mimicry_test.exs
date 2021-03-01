defmodule MimicryTest do
  use ExUnit.Case
  doctest Mimicry

  test "greets the world" do
    assert Mimicry.hello() == :world
  end
end
