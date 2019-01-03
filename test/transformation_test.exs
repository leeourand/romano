defmodule TransformationTest do
  use ExUnit.Case, async: true
  alias Romano.Matrix
  alias Romano.Transformation
  import Romano.Tuple, only: [point: 3, vector: 3]

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
    assert Matrix.multiply(translation, p) == Romano.Tuple.point( 0, 1, 0)

    translation = Transformation.rotation_z(:math.pi() / 4)
    assert Romano.Tuple.about_equal?(Matrix.multiply(translation, p), Romano.Tuple.point(:math.sqrt(2) / -2, :math.sqrt(2) / 2, 0))
  end

  test "shearing a point" do
    p = Romano.Tuple.point(2, 3, 4)
    translation = Transformation.shearing(1, 0, 0, 0, 0, 0)
    assert Matrix.multiply(translation, p) == Romano.Tuple.point(5, 3, 4)
  end

  test "chained transformations" do
    p = point(1, 0, 1)
    a = Transformation.rotation_x(:math.pi() / 2)
    b = Transformation.scale(5, 5, 5)
    c = Transformation.translation(10, 5, 7)
    result =  Matrix.multiply(c, b)
        |> Matrix.multiply(a)
        |> Matrix.multiply(p)
    assert result == point(15, 0, 7)
  end

  test "the transformation matrix for the default world orientation" do
    from = point(0, 0, 0)
    to = point(0, 0, -1)
    up = vector(0, 1, 0)
    t = Transformation.view_transform(from, to, up)
    assert t == Matrix.identity()
  end

  test "A view transformation matrix looking in the positive z direction" do
    from = point(0, 0, 0)
    to = point(0, 0, 1)
    up = vector(0, 1, 0)
    t = Transformation.view_transform(from, to, up)
    assert Matrix.equal?(t, Transformation.scale(-1, 1, -1))
  end

  test "A view transformation moves the world" do
    from = point(0, 0, 8)
    to = point(0, 0, 0)
    up = vector(0, 1, 0)
    t = Transformation.view_transform(from, to, up)
    assert t == Transformation.translation(0, 0, -8)
  end

  test "An arbitrary view transformation" do
    from = point(1, 3, 2)
    to = point(4, -2, 8)
    up = vector(1, 1, 0)
    t = Transformation.view_transform(from, to, up)
    expected = Matrix.new([
      [-0.50709, 0.50709, 0.67612, -2.36643],
      [0.76772, 0.60609, 0.12122, -2.82843],
      [-0.35857, 0.59761, -0.71714, 0.00],
      [0.00, 0.00, 0.00, 1.00]
    ])
    assert Matrix.equal?(expected, t)
  end
end
