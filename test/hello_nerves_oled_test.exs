defmodule HelloNervesOledTest do
  use ExUnit.Case
  doctest HelloNervesOled

  test "greets the world" do
    assert HelloNervesOled.hello() == :world
  end
end
