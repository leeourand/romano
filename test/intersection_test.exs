defmodule IntersectionTest do
  use ExUnit.Case, async: true
  alias Romano.Intersection
  alias Romano.Shape
  alias Romano.Sphere
  alias Romano.Ray
  alias Romano.Transformation
  import Romano.Tuple, only: [point: 3, vector: 3, z: 1]

  test "creating an intersection" do
    s = Shape.sphere()
    i = Intersection.new(3.5, s)
    assert i.object == s
    assert i.t == 3.5
  end

  test "the hit when all t values are positive" do
    s = Shape.sphere()
    i1 = Intersection.new(1, s)
    i2 = Intersection.new(2, s)
    assert Intersection.hit([i1, i2]) == i1
  end

  test "the hit when some t values are negative" do
    s = Shape.sphere()
    i1 = Intersection.new(-1, s)
    i2 = Intersection.new(2, s)
    assert Intersection.hit([i1, i2]) == i2
  end

  test "the hit when all t values are negative" do
    s = Shape.sphere()
    i1 = Intersection.new(-1, s)
    i2 = Intersection.new(-2, s)
    assert Intersection.hit([i1, i2]) == nil
  end

  test "the hit when an intersection occurs on the outside" do
    r = Ray.new(point(0, 0, -5), vector(0, 0, 1))
    shape = Shape.sphere()
    i = Intersection.new(4, shape)
    comps = Intersection.prepare_computations(i, r)
    assert comps.inside == false
  end

  test "the hit when an intersection occurs on the inside" do
    r = Ray.new(point(0, 0, 0), vector(0, 0, 1))
    shape = Shape.sphere()
    i = Intersection.new(1, shape)
    comps = Intersection.prepare_computations(i, r)
    assert comps.point == point(0, 0, 1)
    assert comps.eyev == vector(0, 0, -1)
    assert comps.inside == true
    assert comps.normalv == vector(0, 0, -1) # Inverted because the hit is *inside* the shape
  end

  test "precomputing the state of an intersection" do
    r = Ray.new(point(0, 0, -5), vector(0, 0 ,1))
    shape = Shape.sphere()
    i = Intersection.new(4, shape)
    comps = Intersection.prepare_computations(i, r)
    assert comps.t == i.t
    assert comps.object == i.object
    assert comps.point == point(0, 0, -1)
    assert comps.eyev == vector(0, 0, -1)
    assert comps.normalv == vector(0, 0, -1)
  end

  test "the hit should offset the point" do
    r = Ray.new(point(0, 0, -5), vector(0, 0, 1))
    shape = Shape.sphere()
            |> Shape.set_transform(Transformation.translation(0, 0, 1))
    i = Intersection.new(5, shape)
    comps = Intersection.prepare_computations(i, r)
    assert z(comps.over_point) < (-Romano.epsilon() / 2)
    assert z(comps.point) > z(comps.over_point)
  end

  test "precomputing the reflection vector" do
    shape = Shape.plane()
    r = Ray.new(point(0, 1, -1), vector(0, -:math.sqrt(2) / 2, :math.sqrt(2)/2))
    i = Intersection.new(:math.sqrt(2), shape)
    comps = Intersection.prepare_computations(i, r)
    assert comps.reflectv == vector(0, :math.sqrt(2)/2, :math.sqrt(2)/2)
  end

  test "finding n1 and n2 at various intersections" do
    a = Sphere.glass_sphere()
        |> Shape.set_transform(Transformation.scale(2, 2, 2))
        |> put_in([:material, :refractive_index], 1.5)
    b = Sphere.glass_sphere()
        |> Shape.set_transform(Transformation.translation(0, 0, -0.25))
        |> put_in([:material, :refractive_index], 2.0)
    c = Sphere.glass_sphere()
        |> Shape.set_transform(Transformation.translation(0, 0, 0.25))
        |> put_in([:material, :refractive_index], 2.5)
    r = Ray.new(point(0, 0, -4), vector(0, 0, 1))
    xs = [Intersection.new(2, a), Intersection.new(2.75, b), Intersection.new(3.25, c), Intersection.new(4.75, b), Intersection.new(5.25, c), Intersection.new(6, a)]
    [
      {0, 1.0, 1.5},
      {1, 1.5, 2.0},
      {2, 2.0, 2.5},
      {3, 2.5, 2.5},
      {4, 2.5, 1.5},
      {5, 1.5, 1.0}
    ] |> Enum.each(fn {index, n1, n2} ->
      comps = Intersection.prepare_computations(Enum.at(xs, index), r, xs)
      assert comps.n1 == n1
      assert comps.n2 == n2
    end)
  end

  test "the under point is offset below the surface" do
    r = Ray.new(point(0, 0, -5), vector(0, 0, 1))
    shape = Sphere.glass_sphere()
            |> Shape.set_transform(Transformation.translation(0, 0, 1))
    i = Intersection.new(5, shape)
    xs = [i]
    comps = Intersection.prepare_computations(i, r, xs)
    assert z(comps.under_point) > Romano.epsilon()/2
    assert z(comps.point) < z(comps.under_point)
  end

  test "the schlick approximation under total internal reflection" do
    shape = Sphere.glass_sphere()
    r = Ray.new(point(0, 0, :math.sqrt(2)/2), vector(0, 1, 0))
    xs = [Intersection.new(-:math.sqrt(2)/2, shape), Intersection.new(:math.sqrt(2)/2, shape)]
    comps = Intersection.prepare_computations(Enum.at(xs, 1), r, xs)
    reflectance = Intersection.schlick(comps)
    assert reflectance == 1.0
  end

  test "the schlick approximation with a perpendicular viewing angle" do
    shape = Sphere.glass_sphere()
    r = Ray.new(point(0, 0, 0), vector(0, 1, 0))
    xs = [Intersection.new(-1, shape), Intersection.new(1, shape)]
    comps = Intersection.prepare_computations(Enum.at(xs, 1), r, xs)
    reflectance = Intersection.schlick(comps)
    assert Float.round(reflectance, 5) == 0.04
  end

  test "the schlick approximation with a small angle and n2 > n1" do
    shape = Sphere.glass_sphere()
    r = Ray.new(point(0, 0.99, -2), vector(0, 0, 1))
    xs = [Intersection.new(1.8589, shape)]
    comps = Intersection.prepare_computations(Enum.at(xs, 0), r, xs)
    reflectance = Intersection.schlick(comps)
    assert Float.round(reflectance, 5) == 0.48873
  end
end
