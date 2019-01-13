defmodule Romano.Cube do
  alias Romano.Intersection
  alias Romano.Shape
  import Romano.Tuple, only: [x: 1, y: 1, z: 1, vector: 3]

  def local_normal_at(cube, point) do
    abs_x = abs(x(point))
    abs_y = abs(y(point))
    abs_z = abs(z(point))
    maxc = Enum.max([abs_x, abs_y, abs_z])

    case maxc do
      ^abs_x ->
        vector(x(point), 0, 0)
      ^abs_y ->
        vector(0, y(point), 0)
      ^abs_z ->
        vector(0, 0, z(point))
      _ ->
        raise "Invalid point"
    end
  end

  def local_intersect(cube = %Shape{name: :cube}, ray) do
    {xtmin, xtmax} = check_axis(x(ray.origin), x(ray.direction))
    {ytmin, ytmax} = check_axis(y(ray.origin), y(ray.direction))
    {ztmin, ztmax} = check_axis(z(ray.origin), z(ray.direction))

    tmin = Enum.max([xtmin, ytmin, ztmin])
    tmax = Enum.min([xtmax, ytmax, ztmax])

    if tmin > tmax do
      []
    else
      [Intersection.new(tmin, cube), Intersection.new(tmax, cube)]
    end
  end

  defp check_axis(origin, direction) do
    tmin_numerator = (-1 - origin)
    tmax_numerator = (1 - origin)

    {tmin, tmax} = if abs(direction) >= Romano.epsilon() do
      {tmin_numerator / direction, tmax_numerator / direction}
    else
      {tmin_numerator * Romano.huge_number(), tmax_numerator * Romano.huge_number()}
    end

    if tmin > tmax do
      {tmax, tmin}
    else
      {tmin, tmax}
    end
  end
end
