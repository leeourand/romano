defmodule PatternTest do
  use ExUnit.Case, async: true
  alias Romano.Color
  alias Romano.Matrix
  alias Romano.Pattern
  alias Romano.Shape
  alias Romano.Transformation
  import Romano.Tuple, only: [point: 3]

  def white do
    Color.new(1, 1, 1)
  end

  def black do
    Color.new(0, 0, 0)
  end

  test "creating a stripe pattern" do
    pattern = Pattern.stripe(white(), black())
    assert pattern.a == white()
    assert pattern.b == black()
  end

  test "a stripe pattern is constant in y" do
    pattern = Pattern.stripe(white(), black())
    assert Pattern.pattern_at_shape(pattern, Shape.test(), point(0, 0, 0)) == white()
    assert Pattern.pattern_at_shape(pattern, Shape.test(), point(0, 1, 0)) == white()
    assert Pattern.pattern_at_shape(pattern, Shape.test(), point(0, 2, 0)) == white()
  end

  test "a stripe pattern is constant in z" do
    pattern = Pattern.stripe(white(), black())
    assert Pattern.pattern_at_shape(pattern, Shape.test(), point(0, 0, 0)) == white()
    assert Pattern.pattern_at_shape(pattern, Shape.test(), point(0, 0, 1)) == white()
    assert Pattern.pattern_at_shape(pattern, Shape.test(), point(0, 0, 2)) == white()
  end

  test "a stripe pattern alternates in x" do
    pattern = Pattern.stripe(white(), black())
    assert Pattern.pattern_at_shape(pattern, Shape.test(), point(0, 0, 0)) == white()
    assert Pattern.pattern_at_shape(pattern, Shape.test(), point(0.9, 0, 0)) == white()
    assert Pattern.pattern_at_shape(pattern, Shape.test(), point(1, 0, 0)) == black()
    assert Pattern.pattern_at_shape(pattern, Shape.test(), point(-1, 0, 0)) == black()
    assert Pattern.pattern_at_shape(pattern, Shape.test(), point(-1.1, 0, 0)) == white()
  end

  test "pattern with an object transformation" do
    object = Shape.sphere()
             |> Shape.set_transform(Transformation.scale(2, 2, 2))
    pattern = Pattern.test()
    c = Pattern.pattern_at_shape(pattern, object, point(2, 3, 4))
    assert c == Color.new(1, 1.5, 2)
  end

  test "pattern with a pattern transformation" do
    object = Shape.sphere()
    pattern = Pattern.test()
              |> Pattern.set_transform(Transformation.scale(2, 2, 2))
    c = Pattern.pattern_at_shape(pattern, object, point(2, 3, 4))
    assert c == Color.new(1, 1.5, 2)
  end

  test "pattern with both a pattern transformation and an object transformation" do
    object = Shape.sphere()
             |> Shape.set_transform(Transformation.scale(2, 2, 2))
    pattern = Pattern.test()
              |> Pattern.set_transform(Transformation.translation(0.5, 1, 1.5))
    c = Pattern.pattern_at_shape(pattern, object, point(2.5, 3, 3.5))
    assert c == Color.new(0.75, 0.5, 0.25)
  end

  test "the default pattern transformation" do
    p = Pattern.test()
    assert p.transform == Matrix.identity()
  end

  test "assigning a transformation" do
    p = Pattern.test()
        |> Pattern.set_transform(Transformation.translation(1, 2, 3))
    assert p.transform == Transformation.translation(1, 2, 3)
  end
end
