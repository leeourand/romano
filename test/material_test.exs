defmodule MaterialTest do
  use ExUnit.Case, async: true
  alias Romano.Color
  alias Romano.Light
  alias Romano.Material
  alias Romano.Pattern
  alias Romano.Shape
  import Romano.Tuple, only: [point: 3, vector: 3, about_equal?: 2]

  test "the default material" do
    m = Material.new()
    assert m.color == Color.new(1, 1, 1)
    assert m.ambient == 0.1
    assert m.diffuse == 0.9
    assert m.specular == 0.9
    assert m.shininess == 200
  end

  test "lighting with the eye between the light and the surface" do
    m = Material.new()
    position = point(0, 0, 0)
    eyev = vector(0, 0, -1)
    normalv = vector(0, 0, -1)
    light = Light.point_light(point(0, 0, -10), Color.new(1, 1, 1))
    assert Material.lighting(m, Shape.test(), light, position, eyev, normalv, false) == Color.new(1.9, 1.9, 1.9)
  end

  test "lighting with the eye between the light and the surface, eye offset by 45 degrees" do
    m = Material.new()
    position = point(0, 0, 0)
    eyev = vector(0, :math.sqrt(2)/2, :math.sqrt(2)/2)
    normalv = vector(0, 0, -1)
    light = Light.point_light(point(0, 0, -10), Color.new(1, 1, 1))
    assert Material.lighting(m, Shape.test(), light, position, eyev, normalv, false) == Color.new(1.0, 1.0, 1.0)
  end

  test "lighting with the eye opposite the surface, light offset by 45 degrees " do
    m = Material.new()
    position = point(0, 0, 0)
    eyev = vector(0, 0, -1)
    normalv = vector(0, 0, -1)
    light = Light.point_light(point(0, 10, -10), Color.new(1, 1, 1))
    assert about_equal?(Material.lighting(m, Shape.test(), light, position, eyev, normalv, false), Color.new(0.7364, 0.7364, 0.7364))
  end

  test "lighting with the eye in the path of the reflection vector" do
    m = Material.new()
    position = point(0, 0, 0)
    eyev = vector(0, -:math.sqrt(2)/2, -:math.sqrt(2)/2)
    normalv = vector(0, 0, -1)
    light = Light.point_light(point(0, 10, -10), Color.new(1, 1, 1))
    assert about_equal?(Material.lighting(m, Shape.test(), light, position, eyev, normalv, false), Color.new(1.6364, 1.6364, 1.6364))
  end

  test "lighting with the eye behind the surface" do
    m = Material.new()
    position = point(0, 0, 0)
    eyev = vector(0, 0, -1)
    normalv = vector(0, 0, -1)
    light = Light.point_light(point(0, 0, 10), Color.new(1, 1, 1))
    assert Material.lighting(m, Shape.test(), light, position, eyev, normalv, false) == Color.new(0.1, 0.1, 0.1)
  end

  test "lighting with the surface in shadow" do
    m = Material.new()
    position = point(0, 0, 0)
    eyev = vector(0, 0, -1)
    normalv = vector(0, 0, -1)
    light = Light.point_light(point(0, 0, -10), Color.new(1, 1, 1))
    in_shadow = true
    result = Material.lighting(m, Shape.test(), light, position, eyev, normalv, in_shadow)
    assert result == Color.new(0.1, 0.1, 0.1)
  end

  test "lighting with a pattern applied" do
    m = %{Material.new |
      pattern: Pattern.stripe(Color.new(1, 1, 1), Color.new(0, 0, 0)),
      ambient: 1,
      diffuse: 0,
      specular: 0}
    eyev = vector(0, 0, -1)
    normalv = vector(0, 0, -1)
    light = Light.point_light(point(0, 0, -10), Color.new(1, 1, 1))
    c1 = Material.lighting(m, Shape.test(), light, point(0.9, 0, 0), eyev, normalv, false)
    c2 = Material.lighting(m, Shape.test(), light, point(1.1, 0, 0), eyev, normalv, false)
    assert c1 == Color.new(1, 1, 1)
    assert c2 == Color.new(0, 0, 0)
  end
end
