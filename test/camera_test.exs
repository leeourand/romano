defmodule CameraTest do
  use ExUnit.Case, async: true
  alias Romano.Camera
  alias Romano.Canvas
  alias Romano.Color
  alias Romano.Matrix
  alias Romano.Transformation
  alias Romano.World

  import Romano.Tuple, only: [point: 3, vector: 3, about_equal?: 2]

  test "constructing a camera" do
    hsize = 160
    vsize = 120
    field_of_view = :math.pi() / 2
    c = Camera.new(hsize, vsize, field_of_view)
    assert c.hsize == 160
    assert c.vsize == 120
    assert c.field_of_view == :math.pi() / 2
    assert c.transform == Matrix.identity()
  end

  test "the pixel size for a horizontal canvas" do
    c = Camera.new(200, 125, :math.pi() / 2)
    assert Float.round(Camera.pixel_size(c), 5) == 0.01
  end

  test "the pixel size for a vertical canvas" do
    c = Camera.new(125, 200, :math.pi() / 2)
    assert Float.round(Camera.pixel_size(c), 5) == 0.01
  end

  test "constructing a ray through the center of the canvas" do
    c = Camera.new(201, 101, :math.pi() / 2)
    r = Camera.ray_for_pixel(c, 100, 50)
    assert r.origin == point(0, 0, 0)
    assert about_equal?(r.direction, vector(0, 0, -1))
  end

  test "constructing a ray through a corner of the canvas" do
    c = Camera.new(201, 101, :math.pi() / 2)
    r = Camera.ray_for_pixel(c, 0, 0)
    assert r.origin == point(0, 0, 0)
    assert about_equal?(r.direction, vector(0.66519, 0.33259, -0.66851))
  end

  test "constructing a ray when the camera is transformed" do
    c = Camera.new(201, 101, :math.pi() / 2)
    t = Transformation.rotation_y(:math.pi() / 4)
        |> Matrix.multiply(Transformation.translation(0, -2, 5))
    c = Camera.set_transform(c, t)
    r = Camera.ray_for_pixel(c, 100, 50)
    assert about_equal?(r.origin, point(0, 2, -5))
    assert about_equal?(r.direction, vector(:math.sqrt(2)/2, 0, -:math.sqrt(2)/2))
  end

  test "rendering a world with a camera" do
    w = World.default()
    c = Camera.new(11, 11, :math.pi() / 2)
    from = point(0, 0, -5)
    to = point(0, 0, 0)
    up = vector(0, 1, 0)
    c = %{c | transform: Transformation.view_transform(from, to, up)}
    image = Camera.render(c, w)
    assert about_equal?(Canvas.pixel_at(image, {5, 5}), Color.new(0.38066, 0.47583, 0.2855))
  end
end
