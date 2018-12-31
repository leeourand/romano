defmodule WorldTest do
  use ExUnit.Case, async: true
  alias Romano.Color
  alias Romano.Intersection
  alias Romano.Light
  alias Romano.Material
  alias Romano.Ray
  alias Romano.Shape
  alias Romano.Transformation
  alias Romano.World
  import Romano.Tuple, only: [point: 3, vector: 3]

  test "creating a world" do
    w = World.new()
    assert Enum.count(w.objects) == 0
    assert w.light == nil
  end

  test "the default world" do
    light = Light.point_light(point(-10, 10, -10), Color.new(1, 1, 1))
    s1 = put_in(Shape.sphere().material.color, Color.new(0.8, 1, 0.6))
    |> put_in([Access.key!(:material), Access.key!(:diffuse)], 0.7)
    |> put_in([Access.key!(:material), Access.key!(:specular)], 0.2)
    s2 = Shape.sphere()
    |> Shape.set_transform(Transformation.scale(0.5, 0.5, 0.5))

    w = World.default()
    assert w.light == light
    assert Enum.member? w.objects, s1
    assert Enum.member? w.objects, s2
  end

  test "intersecting a world with a ray" do
    w = World.default()
    r = Ray.new(point(0, 0, -5), vector(0, 0, 1))
    xs = Ray.intersect_world(w, r)
    assert Enum.at(xs, 0).t == 4
    assert Enum.at(xs, 1).t == 4.5
    assert Enum.at(xs, 2).t == 5.5
    assert Enum.at(xs, 3).t == 6
  end

  test "shading an intersection" do
    w = World.default()
    r = Ray.new(point(0, 0, -5), vector(0, 0, 1))
    shape = List.first(w.objects)
    i = Intersection.new(4, shape)
    comps = Intersection.prepare_computations(i, r)
    c = Material.shade_hit(w, comps)
    assert Romano.Tuple.about_equal?(Color.new(0.38066, 0.47583, 0.2855), c)
  end

  test "shading an intersection from the inside" do
    w = World.default()
    w = %{w | light: Light.point_light(point(0, 0.25, 0), Color.new(1, 1, 1))}
    r = Ray.new(point(0, 0, 0), vector(0, 0, 1))
    shape = Enum.at(w.objects, 1)
    i = Intersection.new(0.5, shape)
    comps = Intersection.prepare_computations(i, r)
    c = Material.shade_hit(w, comps)
    assert Romano.Tuple.about_equal?(Color.new(0.90498, 0.90498, 0.90498), c)
  end

  test "the color when a ray misses" do
    w = World.default()
    r = Ray.new(point(0, 0, -5), vector(0, 1, 0))
    c = World.color_at(w, r)
    assert c == Color.new(0, 0, 0)
  end

  test "the color when a ray hits" do
    w = World.default()
    r = Ray.new(point(0, 0, -5), vector(0, 0, 1))
    c = World.color_at(w, r)
    assert Romano.Tuple.about_equal?(Color.new(0.38066, 0.47583, 0.2855), c)
  end

  test "the color with an intersection behind the ray" do
    w = put_in(World.default(), [:objects, Access.at(0), :material, :ambient], 1)
    w = put_in(w, [:objects, Access.at(1), :material, :ambient], 1)
    r = Ray.new(point(0, 0, 0.75), vector(0, 0, -1))
    c = World.color_at(w, r)
    assert c == Enum.at(w.objects, 1).material.color
  end

  test "there is no shadow when nothing is collinear with point and light" do
    w = World.default()
    p = point(0, 10, 0)
    refute World.is_shadowed(w, p)
  end

  test "there is a shadow when an object is between the point and the light" do
    w = World.default()
    p = point(10, -10, 10)
    assert World.is_shadowed(w, p)
  end

  test "there is no shadow when an object is behind the light" do
    w = World.default()
    p = point(-20, 20, -20)
    refute World.is_shadowed(w, p)
  end

  test "there is no shadow when an object is behind the point" do
    w = World.default()
    p = point(-2, 2, -2)
    refute World.is_shadowed(w, p)
  end

  test "shade_hit() is given an intersection in shadow" do
    s1 = Shape.sphere()
    s2 = Shape.sphere()
         |> Shape.set_transform(Transformation.translation(0, 0, 10))
    w = World.default()
        |> put_in([:light], Light.point_light(point(0, 0, -10), Color.new(1, 1, 1)))
        |> put_in([:objects], [s1, s2])
    r = Ray.new(point(0, 0, 5), vector(0, 0, 1))
    i = Intersection.new(4, s2)
    comps = Intersection.prepare_computations(i, r)
    c = Material.shade_hit(w, comps)
    assert c == Color.new(0.1, 0.1, 0.1)
  end
end
