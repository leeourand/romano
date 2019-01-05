defmodule Romano do
  alias Romano.Camera
  alias Romano.Canvas
  alias Romano.Color
  alias Romano.Intersection
  alias Romano.Light
  alias Romano.Material
  alias Romano.Matrix
  alias Romano.Pattern
  alias Romano.Ray
  alias Romano.Shape
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
          normal = Shape.normal_at(hit.object, point)
          eye = multiply(r.direction, -1)
          color = Material.lighting(hit.object.material, hit.object, light, point, eye, normal, false)
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

  def draw_spheres_scene do
    floor = Shape.plane()
            |> put_in([:material, :pattern], Pattern.checkers(Color.new(1, 1, 1), Color.new(0.95, 0.95, 0.95))
                                             |> Pattern.set_transform(Transformation.rotation_y(:math.pi() /6)))
            |> put_in([:material, :specular], 0)
            |> put_in([:material, :reflective], 0.3)

    middle = Shape.sphere()
             |> Shape.set_transform(Transformation.translation(-0.5, 1, 0.5)
                                    |> Matrix.multiply(Transformation.rotation_z(:math.pi()/6)))
             |> put_in([:material, :pattern], Pattern.checkers(Color.new(0, 1, 1), Color.new(0.1, 0.2, 0.95))
                                              |> Pattern.set_transform(Transformation.scale(0.4, 0.4, 0.4)))
             |> put_in([:material, :diffuse], 0.7)
             |> put_in([:material, :specular], 0.3)

    right = Shape.sphere()
            |> Shape.set_transform(Transformation.translation(1.5, 0.5, -0.5)
                                   |> Matrix.multiply(Transformation.scale(0.5, 0.5, 0.5))
                                   |> Matrix.multiply(Transformation.rotation_x(:math.pi()/4))
                                   |> Matrix.multiply(Transformation.rotation_z(:math.pi()/4)))
            |> put_in([:material, :pattern], Pattern.gradient(Color.new(0, 1, 0.1), Color.new(0.1, 1, 0.95))
                                             |> Pattern.set_transform(Transformation.scale(2, 2, 2)))
            |> put_in([:material, :diffuse], 0.7)
            |> put_in([:material, :specular], 0.3)
            |> put_in([:material, :reflective], 0.3)

    left = Shape.sphere()
           |> Shape.set_transform(Transformation.translation(-1.5, 0.33, -0.75)
                                  |> Matrix.multiply(Transformation.scale(0.33, 0.33, 0.33)))
           |> put_in([:material, :pattern], Pattern.stripe(Color.new(1, 0.1, 0.1), Color.new(1, 1, 0))
                                            |> Pattern.set_transform(Transformation.rotation_y(:math.pi()/6)
                                                                     |> Matrix.multiply(Transformation.scale(0.4, 0.4, 0.4))))
           |> put_in([:material, :diffuse], 0.7)
           |> put_in([:material, :specular], 0.3)
           |> put_in([:material, :reflective], 0.3)

    front = Shape.sphere()
           |> Shape.set_transform(Transformation.translation(-0.6, 0.6, -0.7)
                                  |> Matrix.multiply(Transformation.scale(0.6, 0.6, 0.6)))
           |> put_in([:material, :color], Color.new(0.5, 0.5, 0.5))
           |> put_in([:material, :ambient], 0.00)
           |> put_in([:material, :diffuse], 0.00)
           |> put_in([:material, :shininess], 300)
           |> put_in([:material, :specular], 1.0)
           |> put_in([:material, :reflective], 0.9)
           |> put_in([:material, :transparency], 1.0)
           |> put_in([:material, :refractive_index], 1.5)

    world = World.new
            |> put_in([:light], Light.point_light(point(-10, 10, -10), Color.new(1, 1, 1)))
            |> put_in([:objects], [floor, middle, right, left, front])

    camera = Camera.new(600, 400, :math.pi() / 3)
             |> put_in([:transform], Transformation.view_transform(point(0, 1.5, -5), point(0, 1, 0), vector(0, 1, 0)))

    data = Camera.render(camera, world)
           |> Canvas.to_ppm
    File.write("world_out.ppm", data)
  end

  def draw_snowman_scene do
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

    bottom = Shape.sphere()
             |> Shape.set_transform(Transformation.translation(0.7, 0.5, -1.5))
             |> put_in([:material, :color], Color.new(1, 1, 1))
             |> put_in([:material, :diffuse], 0.7)
             |> put_in([:material, :specular], 0.3)

    middle = Shape.sphere()
            |> Shape.set_transform(Transformation.translation(0.7, 1.83, -1.5)
                                   |> Matrix.multiply(Transformation.scale(0.66, 0.66, 0.66)))
            |> put_in([:material, :color], Color.new(1, 1, 1))
            |> put_in([:material, :diffuse], 0.7)
            |> put_in([:material, :specular], 0.3)

    top = Shape.sphere()
           |> Shape.set_transform(Transformation.translation(0.7, 2.67, -1.5)
                                  |> Matrix.multiply(Transformation.scale(0.36, 0.36, 0.36)))
           |> put_in([:material, :color], Color.new(1, 1, 1))
           |> put_in([:material, :diffuse], 0.7)
           |> put_in([:material, :specular], 0.3)

    leye = Shape.sphere
           |> Shape.set_transform(Transformation.translation(0.58, 2.75, -1.79)
                                  |> Matrix.multiply(Transformation.scale(0.06, 0.06, 0.06)))
           |> put_in([:material, :color], Color.new(0.1, 0.1, 0.1))
           |> put_in([:material, :diffuse], 0.91)
           |> put_in([:material, :specular], 0.01)

    reye = Shape.sphere
           |> Shape.set_transform(Transformation.translation(0.82, 2.75, -1.79)
                                  |> Matrix.multiply(Transformation.scale(0.06, 0.06, 0.06)))
           |> put_in([:material, :color], Color.new(0.1, 0.1, 0.1))
           |> put_in([:material, :diffuse], 0.91)
           |> put_in([:material, :specular], 0.01)

    carrot = Shape.sphere
             |> Shape.set_transform(Transformation.translation(0.7, 2.69, -1.79)
                                    |> Matrix.multiply(Transformation.scale(0.08, 0.08, 0.5)))
             |> put_in([:material, :color], Color.new(1.0, 0.5, 0.1))
             |> put_in([:material, :diffuse], 0.81)
             |> put_in([:material, :specular], 0.21)

    world = World.new
            |> put_in([:light], Light.point_light(point(10, 10, -10), Color.new(1.0, 1.0, 1.0)))
            |> put_in([:objects], [floor, left_wall, right_wall, bottom, middle, top, leye, reye, carrot])

    camera = Camera.new(600, 400, :math.pi() / 3)
             |> put_in([:transform], Transformation.view_transform(point(1.5, 1.8, -5.5), point(0.0, 1.5, 0), vector(0, 1, 0)))

    data = Camera.render(camera, world)
           |> Canvas.to_ppm
    File.write("world_out.ppm", data)
  end
end
