defmodule IntersectionTest do
  use ExUnit.Case
  alias Romano.Intersection
  alias Romano.Shape

  test "creating an intersection" do
    s = Shape.sphere()
    i = Intersection.new(3.5, s)
    assert i.object == s
    assert i.t == 3.5
  end

  test "the hit when all t values are positive" do
    s = Shape.sphere()
    i1 = Intersection.new(s, 1)
    i2 = Intersection.new(s, 2)
    assert Intersection.hit([i1, i2]) == i1
  end

  test "the hit when some t values are negative" do
    s = Shape.sphere()
    i1 = Intersection.new(-1, s)
    i2 = Intersection.new(2, s)
    assert Intersection.hit([i1, i2]) == i2
  end

  test "the hit when all t values are negative" do
    s = Shape.sphere()
    i1 = Intersection.new(-1, s)
    i2 = Intersection.new(-2, s)
    assert Intersection.hit([i1, i2]) == nil
  end
end
