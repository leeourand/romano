defmodule ShapeTest do
  use ExUnit.Case, async: true
  alias Romano.Shape
  alias Romano.Material
  alias Romano.Matrix
  alias Romano.Ray
  alias Romano.Transformation
  import Romano.Tuple, only: [point: 3, vector: 3]

  test "default transform is an identity matrix" do
    s = Shape.test()
    assert s.transform == Matrix.identity
  end

  test "setting the transform" do
    s = Shape.test()
    t = Transformation.translation(1, 2, 3)
    s = Shape.set_transform(s, t)
    assert s.transform == t
  end

  test "intersecting a scaled shape" do
    r = Ray.new(point(0, 0, -5), vector(0, 0, 1))
    s = Shape.test()
        |> Shape.set_transform(Transformation.scale(2, 2, 2))
    intersections = Ray.intersects(s, r)
    assert intersections.origin == point(0, 0, -2.5)
    assert intersections.direction == vector(0, 0, 0.5)
  end

  test "intersecting a translated shape with a ray" do
    r = Ray.new(point(0, 0, -5), vector(0, 0, 1))
    s = Shape.test()
        |> Shape.set_transform(Transformation.translation(5, 0, 0))
    intersections = Ray.intersects(s, r)
    assert intersections.origin == point(-5, 0, -5)
    assert intersections.direction == vector(0, 0, 1)
  end

  test "a shape has a default material" do
    s = Shape.test()
    assert s.material == Material.new
  end

  test "assigning a material" do
    s = Shape.test()
    m = %{Material.new() | ambient: 1}
    s = Shape.set_material(s, m)
    assert s.material == m
  end

  test "getting the normal vector on a translated shape" do
    s = Shape.test()
        |> Shape.set_transform(Transformation.translation(0, 1, 0))

    assert Romano.Tuple.about_equal?(Shape.normal_at(s, point(0, 1.70711, -0.70711)), vector(0, 0.70711, -0.70711))
  end

  test "getting the normal vector on a transformed shape" do
    transformation = Transformation.scale(1, 0.5, 1)
    |> Matrix.multiply(Transformation.rotation_z(:math.pi()/5))

    s = Shape.test()
    |> Shape.set_transform(transformation)

    assert Romano.Tuple.about_equal?(Shape.normal_at(s, point(0, :math.sqrt(2)/2, -:math.sqrt(2)/2)), vector(0, 0.97014, -0.24254))
  end
end
