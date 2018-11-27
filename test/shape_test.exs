defmodule ShapeTest do
  use ExUnit.Case
  alias Romano.Shape
  alias Romano.Matrix
  alias Romano.Ray
  alias Romano.Transformation
  import Romano.Tuple, only: [point: 3, vector: 3]

  test "default transform is an identity matrix" do
    s = Shape.sphere()
    assert s.transform == Matrix.identity
  end

  test "setting the transform" do
    s = Shape.sphere()
    t = Transformation.translation(1, 2, 3)
    updated = Shape.set_transform(s, t)
    assert updated.transform == t
  end

  test "intersecting a scaled sphere with a ray" do
    r = Ray.new(point(0, 0, -5), vector(0, 0, 1))
    s = Shape.sphere()
        |> Shape.set_transform(Transformation.scale(2, 2, 2))
    intersections = Ray.intersects(s, r)
    assert List.first(intersections).t == 3
    assert List.last(intersections).t == 7
  end

  test "intersecting a translated sphere with a ray" do
    r = Ray.new(point(0, 0, -5), vector(0, 0, 1))
    s = Shape.sphere()
        |> Shape.set_transform(Transformation.translation(5, 0, 0))
    intersections = Ray.intersects(s, r)
    assert Enum.count(intersections) == 0
  end
end
