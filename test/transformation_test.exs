defmodule TransformationTest do
  use ExUnit.Case
  alias Romano.Matrix
  alias Romano.Transformation

  test "muliplying a point by a translation matrix" do
    translation = Transformation.translation(5, -3, 2)
    p = Romano.Tuple.point(-3, 4, 5)
    moved = Matrix.multiply(translation, p)
    assert moved == Romano.Tuple.point(2, 1, 7)
    assert Matrix.multiply(Matrix.invert(translation), moved) == p
  end

  test "translation does not affect vectors" do
    translation = Transformation.translation(5, -3, 2)
    v = Romano.Tuple.vector(1, 2, 3)
    assert Matrix.multiply(translation, v) == v
  end

  test "scaling a point" do
    translation = Transformation.scale(2, 3, 4)
    p = Romano.Tuple.point(-4, 6, 8)
    assert Matrix.multiply(translation, p) == Romano.Tuple.point(-8, 18, 32)
  end

  test "scaling a vector" do
    translation = Transformation.scale(2, 3, 4)
    v = Romano.Tuple.vector(-8, 9, 2)
    assert Matrix.multiply(translation, v) == Romano.Tuple.vector(-16, 27, 8)
  end

  test "rotating a point" do
    p = Romano.Tuple.point(0, 1, 0)
    translation = Transformation.rotation_x(:math.pi() / 4)
    assert Romano.Tuple.about_equal?(Matrix.multiply(translation, p), Romano.Tuple.point(0, :math.sqrt(2) / 2, :math.sqrt(2) / 2))

    translation = Transformation.rotation_y(:math.pi() / 4)
    assert Romano.Tuple.about_equal?(Matrix.multiply(translation, p), Romano.Tuple.point(:math.sqrt(2) / 2, :math.sqrt(2) / 2, 0))

    translation = Transformation.rotation_z(:math.pi() / 4)
    assert Romano.Tuple.about_equal?(Matrix.multiply(translation, p), Romano.Tuple.point(:math.sqrt(2) / -2, :math.sqrt(2) / 2, 0))
  end

  test "shearing a point" do
    p = Romano.Tuple.point(2, 3, 4)
    translation = Transformation.shearing(1, 0, 0, 0, 0, 0)
    assert Matrix.multiply(translation, p) == Romano.Tuple.point(5, 3, 4)
  end
end
