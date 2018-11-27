defmodule TupleTest do
  use ExUnit.Case, async: true
  alias Romano.Tuple

  test "vectors have a 0 w value" do
    assert Tuple.vector(5, 4, 3) |> Tuple.w == 0
  end

  test "points have a 1 w value" do
    assert Tuple.point(5, 4, 3) |> Tuple.w == 1
  end

  test "x, y, and z values are set" do
    vector = Tuple.vector(5, 4, -3)
    assert Tuple.x(vector) == 5
    assert Tuple.y(vector) == 4
    assert Tuple.z(vector) == -3
  end

  test "adding points and vectors" do
    point = Tuple.point(1, -2, 3)
    vector = Tuple.vector(-1, 2, -3)
    assert Tuple.add(point, vector) == Tuple.point(0, 0, 0)
  end

  test "subtracting two points" do
    point1 = Tuple.point(3, 2, 1)
    point2 = Tuple.point(5, 6, 7)
    assert Tuple.subtract(point1, point2) == Tuple.vector(-2, -4, -6)
  end

  test "subtracting a vector from a point" do
    point = Tuple.point(3, 2, 1)
    vector = Tuple.vector(1, 2, 3)
    assert Tuple.subtract(point, vector) == Tuple.point(2, 0, -2)
  end

  test "subtracting two vectors" do
    vector1 = Tuple.vector(3, 2, 1)
    vector2 = Tuple.vector(9, 8, 7)
    assert Tuple.subtract(vector1, vector2) == Tuple.vector(-6, -6, -6)
  end

  test "negating a tuple" do
    assert Tuple.new(5, -4, 3, -2) |> Tuple.negate == Tuple.new(-5, 4, -3, 2)
  end

  test "multiplying by a scalar" do
    assert Tuple.new(5, -4, 3, -2) |> Tuple.multiply(5) == Tuple.new(25, -20, 15, -10)
    assert Tuple.new(5, -4, 3, -2) |> Tuple.multiply(0.5) == Tuple.new(2.5, -2, 1.5, -1)
  end

  test "dividing by a scalar" do
    assert Tuple.new(5, -4, 3, -2) |> Tuple.divide(2) == Tuple.new(2.5, -2, 1.5, -1)
  end

  test "vector magnitudes" do
    assert Tuple.vector(1, 0, 0) |> Tuple.magnitude == 1
    assert Tuple.vector(0, 1, 0) |> Tuple.magnitude == 1
    assert Tuple.vector(0, 0, 1) |> Tuple.magnitude == 1
    assert Tuple.vector(4, 5, 6) |> Tuple.magnitude == :math.sqrt(77)
    assert Tuple.vector(-1, -2, -3) |> Tuple.magnitude == :math.sqrt(14)
  end

  test "vector normalization" do
    assert Tuple.vector(4, 0, 0) |> Tuple.normalize == Tuple.vector(1.0, 0.0, 0.0)
    assert Tuple.vector(1, 2, 3) |> Tuple.normalize |> Tuple.magnitude == 1
  end

  test "the dot product" do
    v1 = Tuple.vector(1, 2, 3)
    v2 = Tuple.vector(2, 3, 4)
    assert Tuple.dot(v1, v2) == 20
  end

  test "the cross product" do
    v1 = Tuple.vector(1, 2, 3)
    v2 = Tuple.vector(2, 3, 4)
    assert Tuple.cross(v1, v2) == Tuple.vector(-1, 2, -1)
    assert Tuple.cross(v2, v1) == Tuple.vector(1, -2, 1)
  end

  test "reflecting a vector approaching at 45 degrees" do
    v = Tuple.vector(1, -1, 0)
    n = Tuple.vector(0, 1, 0)
    assert Tuple.reflect(v, n) == Tuple.vector(1, 1, 0)
  end

  test "reflecting a vector off a slanted surface" do
    v = Tuple.vector(0, -1, 0)
    n = Tuple.vector(:math.sqrt(2)/2, :math.sqrt(2)/2, 0)
    assert Tuple.about_equal?(Tuple.reflect(v, n), Tuple.vector(1, 0, 0))
  end
end
