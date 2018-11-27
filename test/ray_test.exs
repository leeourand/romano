defmodule RayTest do
  use ExUnit.Case, async: true
  alias Romano.Ray
  alias Romano.Shape
  alias Romano.Intersection
  alias Romano.Transformation
  import Romano.Tuple, only: [point: 3, vector: 3]

  test "creating and querying a ray" do
    origin = point(1, 2, 3)
    direction = vector(4, 5, 6)
    ray = Ray.new(origin, direction)
    assert ray.origin == origin
    assert ray.direction == direction
  end

  test "finding the point from a distance" do
    ray = Ray.new(point(2, 3, 4), vector(1, 0, 0))
    assert Ray.position(ray, 0) == point(2, 3, 4)
    assert Ray.position(ray, 1) == point(3, 3, 4)
    assert Ray.position(ray, 2) == point(4, 3, 4)
  end

  test "intersecting a sphere" do
    ray = Ray.new(point(0, 0, -5), vector(0, 0, 1))
    s = Shape.sphere()
    assert Ray.intersects(s, ray) == [Intersection.new(4.0, s), Intersection.new(6.0, s)]

    ray = Ray.new(point(0, 1, -5), vector(0, 0, 1))
    assert Ray.intersects(s, ray) == [Intersection.new(5.0, s), Intersection.new(5.0, s)]

    ray = Ray.new(point(0, 2, -5), vector(0, 0, 1))
    assert Ray.intersects(s, ray) == []

    ray = Ray.new(point(0, 0, 0), vector(0, 0, 1))
    assert Ray.intersects(s, ray) == [Intersection.new(-1.0, s), Intersection.new(1.0, s)]

    ray = Ray.new(point(0, 0, 5), vector(0, 0, 1))
    assert Ray.intersects(s, ray) == [Intersection.new(-6.0, s), Intersection.new(-4.0, s)]
  end

  test "transforming a ray" do
    ray = Ray.new(point(1, 2, 3), vector(0, 1, 0))
    translation = Transformation.translation(3, 4, 5)
    result = Ray.transform(ray, translation)
    assert result.origin == point(4, 6, 8)
    assert result.direction == vector(0, 1, 0)
  end

  test "scaling a ray" do
    ray = Ray.new(point(1, 2, 3), vector(0, 1, 0))
    translation = Transformation.scale(2, 3, 4)
    result = Ray.transform(ray, translation)
    assert result.origin == point(2, 6, 12)
    assert result.direction == vector(0, 3, 0)
  end
end
