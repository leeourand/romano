defmodule RomanoTest do
  use ExUnit.Case
  doctest Romano

  test "greets the world" do
    assert Romano.hello() == :world
  end
end
