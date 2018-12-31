defmodule Romano.Camera do
  alias Romano.Canvas
  alias Romano.Matrix
  alias Romano.Ray
  alias Romano.World
  import Romano.Tuple, only: [point: 3, normalize: 1, subtract: 2]
  defstruct hsize: 0, vsize: 0, field_of_view: 0, transform: Matrix.identity(), half_view: 0, aspect: 0, inverse_transform: nil
  use Accessible

  def new(hsize, vsize, field_of_view) do
    %__MODULE__{hsize: hsize,
      vsize: vsize,
      field_of_view: field_of_view,
      half_view: :math.tan(field_of_view / 2),
      aspect: hsize * 1.0 / vsize
    }
  end

  def pixel_size(camera) do
    (half_width(camera) * 2) / camera.hsize
  end

  def half_width(camera) do
    if camera.aspect >= 1 do
      camera.half_view
    else
      camera.half_view * camera.aspect
    end
  end

  def half_height(camera) do
    if camera.aspect >= 1 do
      camera.half_view / camera.aspect
    else
      camera.half_view
    end
  end

  def ray_for_pixel(camera, px, py) do
    xoffset = (px + 0.5) * pixel_size(camera)
    yoffset = (py + 0.5) * pixel_size(camera)
    world_x = half_width(camera) - xoffset
    world_y = half_height(camera) - yoffset
    pixel = camera.inverse_transform
            |> Matrix.multiply(point(world_x, world_y, -1))
    origin = camera.inverse_transform
             |> Matrix.multiply(point(0, 0, 0))
    direction = subtract(pixel, origin)
                |> normalize
    Ray.new(origin, direction)
  end

  def render(camera, world) do
    image = Canvas.new(camera.hsize, camera.vsize)
    camera = %{camera | inverse_transform: Matrix.invert(camera.transform)}
    for y <- 0..camera.vsize - 1 do
      for x <- 0..camera.hsize - 1 do
        Task.async(fn ->
          ray = ray_for_pixel(camera, x, y)
          {x, y, World.color_at(world, ray)}
        end)
      end
    end
    |> List.flatten
    |> Task.yield_many(40000)
    |> Enum.map(fn {task, {:ok, res}} -> res end)
    |> Enum.reduce(image, fn ({x, y, color}, c) ->
      Canvas.write_pixel(c, {x, y}, color)
    end)
  end
end
