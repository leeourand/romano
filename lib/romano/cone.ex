defmodule Romano.Cone do
  alias Romano.Intersection
  import Romano.Tuple, only: [x: 1, y: 1, z: 1, vector: 3]

  def local_intersect(cone, ray) do
    a = :math.pow(x(ray.direction), 2) - :math.pow(y(ray.direction), 2) + :math.pow(z(ray.direction), 2)
    b = 2 * x(ray.origin) * x(ray.direction) - 2 * y(ray.origin) * y(ray.direction) + 2 * z(ray.origin) * z(ray.direction)
    c = :math.pow(x(ray.origin), 2) - :math.pow(y(ray.origin), 2) + :math.pow(z(ray.origin), 2)

    cond do
      abs(a) < Romano.epsilon() and abs(b) < Romano.epsilon ->
        intersect_caps([], cone, ray)
      abs(a) < Romano.epsilon() ->
        [Intersection.new(-c/(2*b), cone)]
      true ->
        disc = :math.pow(b, 2) - 4 * a * c
        if disc < 0 do
          []
        else
          Enum.filter([(-b - :math.sqrt(disc)) / (2 * a), (-b + :math.sqrt(disc)) / (2 * a)], fn t ->
            yt = y(ray.origin) + t * y(ray.direction)
            yt > cone.minimum && yt < cone.maximum
          end)
          |> Enum.sort
          |> Enum.map(fn t -> Intersection.new(t, cone) end)
          |> intersect_caps(cone, ray)
        end
    end
  end

  def intersect_caps(xs, cone, ray) do
    if !cone.closed or abs(y(ray.direction)) <= Romano.epsilon() do
      xs
    else
      t = (cone.minimum - y(ray.origin)) / y(ray.direction)
      bottom_intersection = if check_cap(ray, t, cone.minimum) do
        Intersection.new(t, cone)
      end

      t = (cone.maximum - y(ray.origin)) / y(ray.direction)
      top_intersection = if check_cap(ray, t, cone.maximum) do
        Intersection.new(t, cone)
      end


      cap_intersections = [bottom_intersection, top_intersection]
                          |> Enum.reject(&(&1 == nil))
                          xs ++ cap_intersections
    end
  end

  defp check_cap(ray, t, y) do
    x = x(ray.origin) + t * x(ray.direction)
    z = z(ray.origin) + t * z(ray.direction)
    :math.sqrt(:math.pow(x, 2) + :math.pow(z, 2)) <= abs(y)
  end

  def local_normal_at(cone, point) do
    dist = :math.pow(x(point), 2) + :math.pow(z(point), 2)
    cond do
      dist < 1 and y(point) >= cone.maximum - Romano.epsilon() ->
        vector(0, 1, 0)
      dist < 1 and y(point) <= cone.minimum + Romano.epsilon() ->
        vector(0, -1, 0)
      true ->
        y = abs(:math.sqrt(:math.pow(x(point), 2) + :math.pow(z(point), 2)))
        y = if y(point) > 0 do
          -y
        else
          y
        end
        vector(x(point), y, z(point))
    end
  end
end
