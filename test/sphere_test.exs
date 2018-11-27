defmodule SphereTest do
  use ExUnit.Case, async: true
  alias Romano.Shape
  alias Romano.Sphere
  alias Romano.Material
  alias Romano.Transformation
  alias Romano.Matrix
  import Romano.Tuple, only: [point: 3, vector: 3]

  test "getting the normal vector on a sphere at a point on the x-axis" do
    s = Shape.sphere()
    assert Sphere.normal_at(s, point(1, 0, 0)) == vector(1, 0, 0)
  end

  test "getting the normal vector on a sphere at a point on the y-axis" do
    s = Shape.sphere()
    assert Sphere.normal_at(s, point(0, 1, 0)) == vector(0, 1, 0)
  end

  test "getting the normal vector on a sphere at a point on the z-axis" do
    s = Shape.sphere()
    assert Sphere.normal_at(s, point(0, 0, 1)) == vector(0, 0, 1)
  end

  test "getting the normal vector on a sphere at a non-axial point" do
    s = Shape.sphere()
    assert Sphere.normal_at(s, point(:math.sqrt(3)/3, :math.sqrt(3)/3, :math.sqrt(3)/3)) == vector(:math.sqrt(3)/3, :math.sqrt(3)/3, :math.sqrt(3)/3)
  end

  test "getting the normal vector on a translated sphere" do
    s = Shape.sphere()
    |> Shape.set_transform(Transformation.translation(0, 1, 0))
    assert Romano.Tuple.about_equal?(Sphere.normal_at(s, point(0, 1.70711, -0.70711)), vector(0, 0.70711, -0.70711))
  end

  test "getting the normal vector on a transformed sphere" do
    transformation = Transformation.scale(1, 0.5, 1)
    |> Matrix.multiply(Transformation.rotation_z(:math.pi()/5))

    s = Shape.sphere()
    |> Shape.set_transform(transformation)

    assert Romano.Tuple.about_equal?(Sphere.normal_at(s, point(0, :math.sqrt(2)/2, -:math.sqrt(2)/2)), vector(0, 0.97014, -0.24254))
  end

  test "a sphere has a default material" do
    s = Shape.sphere()
    assert s.material == Material.new

  end
end
