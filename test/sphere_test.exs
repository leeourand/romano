defmodule SphereTest do
  use ExUnit.Case, async: true
  alias Romano.Matrix
  alias Romano.Shape
  alias Romano.Sphere
  import Romano.Tuple, only: [point: 3, vector: 3]

  test "getting the normal vector on a sphere at a point on the x-axis" do
    s = Shape.sphere()
    assert Shape.normal_at(s, point(1, 0, 0)) == vector(1, 0, 0)
  end

  test "getting the normal vector on a sphere at a point on the y-axis" do
    s = Shape.sphere()
    assert Shape.normal_at(s, point(0, 1, 0)) == vector(0, 1, 0)
  end

  test "getting the normal vector on a sphere at a point on the z-axis" do
    s = Shape.sphere()
    assert Shape.normal_at(s, point(0, 0, 1)) == vector(0, 0, 1)
  end

  test "getting the normal vector on a sphere at a non-axial point" do
    s = Shape.sphere()
    assert Shape.normal_at(s, point(:math.sqrt(3)/3, :math.sqrt(3)/3, :math.sqrt(3)/3)) == vector(:math.sqrt(3)/3, :math.sqrt(3)/3, :math.sqrt(3)/3)
  end

  test "a helper for producing a sphere with a glassy material" do
    s = Sphere.glass_sphere()
    assert s.transform == Matrix.identity()
    assert s.material.transparency == 1.0
    assert s.material.refractive_index == 1.5
  end
end
