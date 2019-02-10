defmodule Romano.Cylinder do
  alias Romano.Intersection
  import Romano.Tuple, only: [x: 1, y: 1, z: 1, vector: 3]

  def local_intersect(cylinder, ray) do
    a = :math.pow(x(ray.direction), 2) + :math.pow(z(ray.direction), 2)
    if abs(a) < Romano.epsilon() do
      intersect_caps([], cylinder, ray)
    else
      b = 2 * x(ray.origin) * x(ray.direction) + 2 * z(ray.origin) * z(ray.direction)
      c = :math.pow(x(ray.origin), 2) + :math.pow(z(ray.origin), 2) - 1
      disc = :math.pow(b, 2) - 4 * a * c
      if disc < 0 do
        []
      else
        Enum.filter([(-b - :math.sqrt(disc)) / (2 * a), (-b + :math.sqrt(disc)) / (2 * a)], fn t ->
          yt = y(ray.origin) + t * y(ray.direction)
          yt > cylinder.minimum && yt < cylinder.maximum
        end)
        |> Enum.sort
        |> Enum.map(fn t -> Intersection.new(t, cylinder) end)
        |> intersect_caps(cylinder, ray)
      end
    end
  end

  def intersect_caps(xs, cyl, ray) do
    if !cyl.closed or abs(y(ray.direction)) <= Romano.epsilon() do
      xs
    else
      t = (cyl.minimum - y(ray.origin)) / y(ray.direction)
      bottom_intersection = if check_cap(ray, t) do
        Intersection.new(t, cyl)
      end

      t = (cyl.maximum - y(ray.origin)) / y(ray.direction)
      top_intersection = if check_cap(ray, t) do
        Intersection.new(t, cyl)
      end


      cap_intersections = [bottom_intersection, top_intersection]
                          |> Enum.reject(&(&1 == nil))
                          xs ++ cap_intersections
    end
  end

  defp check_cap(ray, t) do
    x = x(ray.origin) + t * x(ray.direction)
    z = z(ray.origin) + t * z(ray.direction)
    :math.pow(x, 2) + :math.pow(z, 2) <= 1
  end

  def local_normal_at(cylinder, point) do
    dist = :math.pow(x(point), 2) + :math.pow(z(point), 2)
    cond do
      dist < 1 and y(point) >= cylinder.maximum - Romano.epsilon() ->
        vector(0, 1, 0)
      dist < 1 and y(point) <= cylinder.minimum + Romano.epsilon() ->
        vector(0, -1, 0)
      true ->
        vector(x(point), 0, z(point))
    end
  end
end
