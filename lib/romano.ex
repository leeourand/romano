defmodule Romano do
  alias Romano.Canvas
  alias Romano.Color
  alias Romano.Shape
  alias Romano.Intersection
  alias Romano.Ray
  alias Romano.Transformation
  import Romano.Tuple, only: [point: 3]

  def epsilon do
    0.000001
  end

  def draw_circle_scene do
    canvas_pixels = 100
    canvas = Canvas.new(canvas_pixels, canvas_pixels)
    color = Color.new(1.0, 0, 0)
    shape = Shape.sphere()
            |> Shape.set_transform(Transformation.shearing(1, 0, 0, 0, 0, 0))
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
          {x, y}
        end
      end
    end
    |> List.flatten
    |> Enum.filter(fn x -> x end)
    |> Enum.reduce(canvas, fn {x, y}, canvas ->
      Canvas.write_pixel(canvas, {x, y}, color)
    end)
    |> Canvas.to_ppm
    File.write("out.ppm", data)
  end
end
