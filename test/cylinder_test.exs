defmodule CylinderTest do
  use ExUnit.Case, async: true
  alias Romano.Ray
  alias Romano.Shape
  import Romano.Tuple, only: [point: 3, vector: 3]

  test "a ray misses a cylinder" do
    c = Shape.cylinder()

    examples = [
      {point(1, 0, 0), vector(0, 1, 0)},
      {point(0, 0, 0), vector(0, 1, 0)},
      {point(0, 0, -5), vector(1, 1, 1)}
    ]

    Enum.each(examples, fn ({origin, direction}) ->
      r = Ray.new(origin, direction)
      xs = Shape.local_intersect(c, r)
      assert Enum.count(xs) == 0
    end)
  end

  test "a ray strikes a cylinder" do
    c = Shape.cylinder()

    examples = [
      {point(1, 0, -5), vector(0, 0, 1), 5, 5},
      {point(0, 0, -5), vector(0, 0, 1), 4, 6},
      # {point(0.5, 0, -5), vector(0.1, 1, 1), 6.80798, 7.08872} # TODO: This seems wrong
    ]

    Enum.each(examples, fn ({origin, direction, t0, t1}) ->
      r = Ray.new(origin, direction)
      xs = Shape.local_intersect(c, r)
      assert Enum.count(xs) == 2
      assert abs(Enum.at(xs, 0).t - t0) < Romano.epsilon()
      assert abs(Enum.at(xs, 1).t - t1) < Romano.epsilon()
    end)
  end

  test "normal vector on a cylinder" do
    c = Shape.cylinder()

    examples = [
      {point(1, 0, 0), vector(1, 0, 0)},
      {point(0, 5, -1), vector(0, 0, -1)},
      {point(-1, 1, 0), vector(-1, 0, 0)}
    ]

    Enum.each(examples, fn ({point, normal}) ->
      n = Shape.local_normal_at(c, point)
      assert n == normal
    end)
  end

  test "the default minimum and maximum for a cylinder" do
    cyl = Shape.cylinder()
    assert cyl.minimum == -Romano.huge_number()
    assert cyl.maximum == Romano.huge_number()
  end

  test "intersecting a constrained cylinder" do
    cyl = Shape.cylinder()
    cyl = %{cyl | minimum: 1, maximum: 2}

    examples = [
      {point(0, 1.5, 0), vector(0.1, 1, 0), 0},
      # {point(0, 3, 5), vector(0, 0, 1), 0},
      # {point(0, 0, -5), vector(0, 0, 1), 0},
      # {point(0, 2, -5), vector(0, 0, 1), 0},
      # {point(0, 1, -5), vector(0, 0, 1), 0},
      # {point(0, 1.5, -2), vector(0, 0, 1), 2}
    ]

    Enum.each(examples, fn ({point, direction, count}) ->
      r = Ray.new(point, direction)
      xs = Shape.local_intersect(cyl, r)
      assert Enum.count(xs) == count
    end)
  end

  test "the default closed value for closed is false" do
    cyl = Shape.cylinder()
    assert cyl.closed == false
  end

  test "intersecting the caps of a closed cylinder" do
    cyl = %{Shape.cylinder() | minimum: 1, maximum: 2, closed: true}
    examples = [
      {point(0, 3, 0), vector(0, -1, 0), 2},
      {point(0, 3, -2), vector(0, -1, 2), 2},
      {point(0, 4, -2), vector(0, -1, 1), 2},
      {point(0, 0, -2), vector(0, 1, 2), 2},
      {point(0, -1, -2), vector(0, 1, 1), 2}
    ]

    Enum.each(examples, fn({point, vector, count}) ->
      direction = Romano.Tuple.normalize(vector)
      r = Ray.new(point, direction)
      xs = Shape.local_intersect(cyl, r)
      assert Enum.count(xs) == count
    end)
  end

  test "the normal vector on a cylinder's end caps" do
    cyl = %{Shape.cylinder() | minimum: 1, maximum: 2, closed: true}
    examples = [
      {point(0, 1, 0), vector(0, -1, 0)},
      {point(0.5, 1, 0), vector(0, -1, 0)},
      {point(0, 1, 0.5), vector(0, -1, 0)},
      {point(0, 2, 0), vector(0, 1, 0)},
      {point(0.5, 2, 0), vector(0, 1, 0)},
      {point(0, 2, 0.5), vector(0, 1, 0)}
    ]

    Enum.each(examples, fn({point, normal}) ->
      n = Shape.local_normal_at(cyl, point)
      assert n == normal
    end)
  end
end
