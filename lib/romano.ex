defmodule Romano do
  alias Romano.Canvas
  alias Romano.Camera
  alias Romano.Color
  alias Romano.Intersection
  alias Romano.Light
  alias Romano.Material
  alias Romano.Matrix
  alias Romano.Ray
  alias Romano.Shape
  alias Romano.Sphere
  alias Romano.Transformation
  alias Romano.World
  import Romano.Tuple, only: [point: 3, vector: 3, multiply: 2]

  def epsilon do
    0.000001
  end

  def draw_circle_scene do
    canvas_pixels = 100
    canvas = Canvas.new(canvas_pixels, canvas_pixels)
    shape = put_in(Shape.sphere().material.color, Color.new(1, 1, 0))
    |> Shape.set_transform(Transformation.shearing(0.6, 0, 0, 0, 0, 0))
    light_position = point(10, -10, -10)
    light_color = Color.new(1, 1, 1)
    light = Light.point_light(light_position, light_color)
    wall_size = 7.0
    half = wall_size / 2
    wall_z = 10.0
    pixel_size = wall_size / canvas_pixels
    ray_origin = point(0, 0, -5)

    data = for y <- 0..canvas_pixels - 1 do
      world_y  = half - pixel_size * y
      for x <- 0..canvas_pixels - 1 do
        world_x = -half + pixel_size * x
        position = point(world_x, world_y, wall_z)
        r = Ray.new(ray_origin, Romano.Tuple.subtract(position, ray_origin) |> Romano.Tuple.normalize)
        hit = Ray.intersects(shape, r)
              |> Intersection.hit()
        if hit do
          point = Ray.position(r, hit.t)
          normal = Sphere.normal_at(hit.object, point)
          eye = multiply(r.direction, -1)
          color = Material.lighting(hit.object.material, light, point, eye, normal, false)
          {x, y, color}
        end
      end
    end
    |> List.flatten
    |> Enum.filter(fn x -> x end)
    |> Enum.reduce(canvas, fn {x, y, color}, canvas ->
      Canvas.write_pixel(canvas, {x, y}, color)
    end)
    |> Canvas.to_ppm
    File.write("out.ppm", data)
  end

  def draw_world_scene do
    floor = Shape.sphere()
            |> Shape.set_transform(Transformation.scale(10, 0.01, 10))
            |> put_in([:material, :color], Color.new(1, 0.9, 0.9))
            |> put_in([:material, :specular], 0)
    left_wall = Shape.sphere()
                |> Shape.set_transform(Transformation.translation(0, 0, 5) |>
                                                                  Matrix.multiply(Transformation.rotation_y(-:math.pi() / 4)) |>
                                                                  Matrix.multiply(Transformation.rotation_x(:math.pi() / 2)) |>
                                                                  Matrix.multiply(Transformation.scale(10, 0.01, 10)))
                |> put_in([:material], floor.material)
    right_wall = Shape.sphere()
                 |> Shape.set_transform(Transformation.translation(0, 0, 5) |>
                                                                   Matrix.multiply(Transformation.rotation_y(:math.pi() / 4)) |>
                                                                   Matrix.multiply(Transformation.rotation_x(:math.pi() / 2)) |>
                                                                   Matrix.multiply(Transformation.scale(10, 0.01, 10)))
                 |> put_in([:material], floor.material)

    middle = Shape.sphere()
             |> Shape.set_transform(Transformation.translation(-0.5, 1, 0.5))
             |> put_in([:material, :color], Color.new(0.1, 1, 0.5))
             |> put_in([:material, :diffuse], 0.7)
             |> put_in([:material, :specular], 0.3)

    right = Shape.sphere()
            |> Shape.set_transform(Transformation.translation(1.5, 0.5, -0.5)
                                   |> Matrix.multiply(Transformation.scale(0.5, 0.5, 0.5)))
            |> put_in([:material, :color], Color.new(0.5, 1, 0.1))
            |> put_in([:material, :diffuse], 0.7)
            |> put_in([:material, :specular], 0.3)

    left = Shape.sphere()
           |> Shape.set_transform(Transformation.translation(-1.5, 0.33, -0.75)
                                  |> Matrix.multiply(Transformation.scale(0.33, 0.33, 0.33)))
           |> put_in([:material, :color], Color.new(1, 0.8, 0.1))
           |> put_in([:material, :diffuse], 0.7)
           |> put_in([:material, :specular], 0.3)

    world = World.new
            |> put_in([:light], Light.point_light(point(-10, 10, -10), Color.new(1, 1, 1)))
            |> put_in([:objects], [floor, left_wall, right_wall, middle, right, left])

    camera = Camera.new(400, 200, :math.pi() / 3)
             |> put_in([:transform], Transformation.view_transform(point(0, 1.5, -5), point(0, 1, 0), vector(0, 1, 0)))

    data = Camera.render(camera, world)
           |> Canvas.to_ppm
    File.write("world_out.ppm", data)
  end
end
