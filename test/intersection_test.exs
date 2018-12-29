defmodule IntersectionTest do
  use ExUnit.Case, async: true
  alias Romano.Intersection
  alias Romano.Shape
  alias Romano.Ray
  import Romano.Tuple, only: [point: 3, vector: 3]

  test "creating an intersection" do
    s = Shape.sphere()
    i = Intersection.new(3.5, s)
    assert i.object == s
    assert i.t == 3.5
  end

  test "the hit when all t values are positive" do
    s = Shape.sphere()
    i1 = Intersection.new(1, s)
    i2 = Intersection.new(2, s)
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

  test "the hit when an intersection occurs on the outside" do
    r = Ray.new(point(0, 0, -5), vector(0, 0, 1))
    shape = Shape.sphere()
    i = Intersection.new(4, shape)
    comps = Intersection.prepare_computations(i, r)
    assert comps.inside == false
  end

  test "the hit when an intersection occurs on the inside" do
    r = Ray.new(point(0, 0, 0), vector(0, 0, 1))
    shape = Shape.sphere()
    i = Intersection.new(1, shape)
    comps = Intersection.prepare_computations(i, r)
    assert comps.point == point(0, 0, 1)
    assert comps.eyev == vector(0, 0, -1)
    assert comps.inside == true
    assert comps.normalv == vector(0, 0, -1) # Inverted because the hit is *inside* the shape
  end

  test "precomputing the state of an intersection" do
    r = Ray.new(point(0, 0, -5), vector(0, 0 ,1))
    shape = Shape.sphere()
    i = Intersection.new(4, shape)
    comps = Intersection.prepare_computations(i, r)
    assert comps.t == i.t
    assert comps.object == i.object
    assert comps.point == point(0, 0, -1)
    assert comps.eyev == vector(0, 0, -1)
    assert comps.normalv == vector(0, 0, -1)
  end
end
