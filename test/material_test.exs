defmodule MaterialTest do
  use ExUnit.Case, async: true
  alias Romano.Material
  alias Romano.Light
  alias Romano.Color
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
    assert Material.lighting(m, light, position, eyev, normalv) == Color.new(1.9, 1.9, 1.9)
  end

  test "lighting with the eye between the light and the surface, eye offset by 45 degrees" do
    m = Material.new()
    position = point(0, 0, 0)
    eyev = vector(0, :math.sqrt(2)/2, :math.sqrt(2)/2)
    normalv = vector(0, 0, -1)
    light = Light.point_light(point(0, 0, -10), Color.new(1, 1, 1))
    assert Material.lighting(m, light, position, eyev, normalv) == Color.new(1.0, 1.0, 1.0)
  end

  test "lighting with the eye opposite the surface, light offset by 45 degrees " do
    m = Material.new()
    position = point(0, 0, 0)
    eyev = vector(0, 0, -1)
    normalv = vector(0, 0, -1)
    light = Light.point_light(point(0, 10, -10), Color.new(1, 1, 1))
    assert about_equal?(Material.lighting(m, light, position, eyev, normalv), Color.new(0.7364, 0.7364, 0.7364))
  end

  test "lighting with the eye in the path of the reflection vector" do
    m = Material.new()
    position = point(0, 0, 0)
    eyev = vector(0, -:math.sqrt(2)/2, -:math.sqrt(2)/2)
    normalv = vector(0, 0, -1)
    light = Light.point_light(point(0, 10, -10), Color.new(1, 1, 1))
    assert about_equal?(Material.lighting(m, light, position, eyev, normalv), Color.new(1.6364, 1.6364, 1.6364))
  end

  test "lighting with the eye behind the surface" do
    m = Material.new()
    position = point(0, 0, 0)
    eyev = vector(0, 0, -1)
    normalv = vector(0, 0, -1)
    light = Light.point_light(point(0, 0, 10), Color.new(1, 1, 1))
    assert Material.lighting(m, light, position, eyev, normalv) == Color.new(0.1, 0.1, 0.1)
  end
end
