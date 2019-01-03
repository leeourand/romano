defmodule PlaneTest do
  use ExUnit.Case, async: true
  alias Romano.Ray
  alias Romano.Shape
  alias Romano.Plane
  import Romano.Tuple, only: [point: 3, vector: 3]

  test "the normal of a plane is constant everywhere" do
    p = Shape.plane()
    n1 = Plane.local_normal_at(p, point(0, 0, 0))
    n2 = Plane.local_normal_at(p, point(10, 0, -10))
    n3 = Plane.local_normal_at(p, point(-5, 0, 150))
    assert n1 == vector(0, 1, 0)
    assert n2 == vector(0, 1, 0)
    assert n3 == vector(0, 1, 0)
  end

  test "intersecting with a ray parallel to the plane" do
    p = Shape.plane()
    r = Ray.new(point(0, 10, 0), vector(0, 0, 1))
    xs = Plane.local_intersect(p, r)
    assert Enum.count(xs) == 0
  end

  test "intersecting with a coplanar ray" do
    p = Shape.plane()
    r = Ray.new(point(0, 0, 0), vector(0, 0, 1))
    xs = Plane.local_intersect(p, r)
    assert Enum.count(xs) == 0
  end

  test "a ray intersecting a plane from above" do
    p = Shape.plane()
    r = Ray.new(point(0, 1, 0), vector(0, -1, 0))
    xs = Plane.local_intersect(p, r)
    assert Enum.count(xs) == 1
    assert Enum.at(xs, 0).t == 1
    assert Enum.at(xs, 0).object == p
  end

  test "a ray intersecting a plane from below" do
    p = Shape.plane()
    r = Ray.new(point(0, -1, 0), vector(0, 1, 0))
    xs = Plane.local_intersect(p, r)
    assert Enum.count(xs) == 1
    assert Enum.at(xs, 0).t == 1
    assert Enum.at(xs, 0).object == p
  end
end
