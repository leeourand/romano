defmodule ColorTest do
  use ExUnit.Case, async: true
  alias Romano.Color
  alias Romano.Tuple

  test "setting rgb values" do
    c = Color.new(0.5, -0.5, -1)
    assert Color.red(c) == 0.5
    assert Color.green(c) == -0.5
    assert Color.blue(c) == -1
  end

  test "adding colors" do
    c1 = Color.new(0.9, 0.6, 0.75)
    c2 = Color.new(0.7, 0.1, 0.25)
    assert Color.add(c1, c2) == Color.new(1.6, 0.7, 1.0)
  end

  test "subtracting colors" do
    c1 = Color.new(0.9, 0.6, 0.75)
    c2 = Color.new(0.7, 0.1, 0.25)
    assert Tuple.about_equal?(Color.subtract(c1, c2), Color.new(0.2, 0.5, 0.5))
  end

  test "multiplying color by scalar" do
    c = Color.new(0.9, 0.6, 0.75)
    assert Color.multiply(c, 2) == Color.new(1.8, 1.2, 1.5)
  end

  test "multiplying colors together" do
    c1 = Color.new(1, 2, 3)
    c2 = Color.new(2, 4, -6)
    assert Color.multiply(c1, c2) == Color.new(2, 8, -18)
  end
end
