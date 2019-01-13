defmodule CubeTest do
  use ExUnit.Case, async: true
  alias Romano.Ray
  alias Romano.Shape
  import Romano.Tuple, only: [point: 3, vector: 3]

  test "a ray intersecting a cube" do
    c = Shape.cube()

    examples = [
      {point(5, 0.5, 0), vector(-1, 0, 0), 4, 6},
      {point(-5, 0.5, 0), vector(1, 0, 0), 4, 6},
      {point(0.5, 5, 0), vector(0, -1, 0), 4, 6},
      {point(0.5, -5, 0), vector(0, 1, 0), 4, 6},
      {point(0.5, 0, 5), vector(0, 0, -1), 4, 6},
      {point(0, 0.5, 0), vector( 0, 0, 1), -1, 1}
    ]

    Enum.each(examples, fn ({origin, direction, t1, t2}) ->
      r = Ray.new(origin, direction)
      xs = Shape.local_intersect(c, r)
      assert Enum.count(xs) == 2
      assert Enum.at(xs, 0).t == t1
      assert Enum.at(xs, 1).t == t2
    end)
  end

  test "a ray missing a cube" do
    c = Shape.cube()

    examples = [
      {point(-2, 0, 0), vector(0.2673, 0.5345, 0.8018)},
      {point(0, -2, 0), vector(0.8018, 0.2673, 0.5345)},
      {point(0, 0, -2), vector(0.5345, 0.8018, 0.2673)},
      {point(2, 0, 2), vector(0, 0, -1)},
      {point(0, 2, 2), vector(0, -1, 0)},
      {point(2, 2, 0), vector(-1, 0, 0)}
    ]

    Enum.each(examples, fn ({origin, direction}) ->
      r = Ray.new(origin, direction)
      xs = Shape.local_intersect(c, r)
      assert Enum.count(xs) == 0
    end)
  end

  test "the normal on the surface of a cube" do
    c = Shape.cube()

    examples = [
      {point(1, 0.5, -0.8), vector(1, 0, 0)},
      {point(-1, -0.2, 0.9), vector(-1, 0, 0)},
      {point(-0.4, 1, -0.1), vector(0, 1, 0)},
      {point(0.3, -1, -0.7), vector(0, -1, 0)},
      {point(-0.6, 0.3, 1), vector(0, 0, 1)},
      {point(0.4, 0.4, -1), vector(0, 0, -1)},
      {point(1, 1, 1), vector(1, 0, 0)},
      {point(-1, -1, -1), vector(-1, 0, 0)}
    ]

    Enum.each(examples, fn {point, normal} ->
      n = Shape.local_normal_at(c, point)
      assert n == normal
    end)
  end

end
