defmodule ConeTest do
  use ExUnit.Case, async: true
  alias Romano.Ray
  alias Romano.Shape
  import Romano.Tuple, only: [point: 3, vector: 3]

  test "Intersecting a cone with a ray" do
    shape = Shape.cone()
    examples = [
      {point(0, 0, -5), vector(0, 0, 1), 5, 5},
      {point(0, 0, -5), vector(1, 1, 1), 8.66025, 8.66025},
      {point(1, 1, -5), vector(-0.5, -1, 1), 4.55006, 49.44994}
    ]

    Enum.each(examples, fn({origin, direction, t0, t1}) ->
      direction = Romano.Tuple.normalize(direction)
      r = Ray.new(origin, direction)
      xs = Shape.local_intersect(shape, r)
      assert Enum.count(xs) == 2
      assert Float.round(Enum.at(xs, 0).t, 5) == t0
      assert Float.round(Enum.at(xs, 1).t, 5) == t1
    end)
  end

  test "intersecting a cone with a ray parellel to one of its halves" do
    shape = Shape.cone()
    direction = Romano.Tuple.normalize(vector(0, 1, 1))
    r = Ray.new(point(0, 0, -1), direction)
    xs = Shape.local_intersect(shape, r)
    assert Enum.count(xs) == 1
    assert Float.round(Enum.at(xs, 0).t, 5) == 0.35355
  end

  test "intersecting a cone's end caps" do
    shape = %{Shape.cone() | maximum: 0.5, minimum: -0.5, closed: true}
    examples = [
      {point(0, 0, -5), vector(0, 1, 0), 0},
      {point(0, 0, -0.25), vector(0, 1, 1), 1},
      {point(0, 0, -0.25), vector(0, 1, 0), 4}
    ]

    Enum.each(examples, fn({origin, direction, count}) ->
      direction = Romano.Tuple.normalize(direction)
      r = Ray.new(origin, direction)
      xs = Shape.local_intersect(shape, r)
      assert Enum.count(xs) == count
    end)
  end

  test "computing the normal vector on a cone" do
    shape = Shape.cone()
    examples = [
      {point(0, 0, 0), vector(0, 0, 0)},
      {point(1, 1, 1), vector(1, -:math.sqrt(2), 1)},
      {point(-1, -1, 0), vector(-1, 1, 0)}
    ]

    Enum.each(examples, fn({point, normal}) ->
      n = Shape.local_normal_at(shape, point)
      assert n == normal
    end)
  end
end
