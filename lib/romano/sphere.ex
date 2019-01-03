defmodule Romano.Sphere do
  alias Romano.Intersection
  alias Romano.Shape
  import Romano.Tuple, only: [point: 3]

  def local_normal_at(%Shape{name: :sphere}, local_point) do
    Romano.Tuple.subtract(local_point, point(0, 0, 0))
  end

  def local_intersect(shape = %Shape{name: :sphere}, ray) do
    center_to_ray = Romano.Tuple.subtract(ray.origin, Romano.Tuple.point(0,0,0))
    a = Romano.Tuple.dot(ray.direction, ray.direction)
    b = 2.0 * Romano.Tuple.dot(ray.direction, center_to_ray)
    c = Romano.Tuple.dot(center_to_ray, center_to_ray) - 1
    discriminant = b * b - 4 * a * c
    case discriminant >= 0 do
      true ->
        [
          Intersection.new(((b * -1.0 - :math.sqrt(discriminant)) / (2 * a)), shape),
          Intersection.new(((b * -1.0 + :math.sqrt(discriminant)) / (2 * a)), shape)
        ]
      false ->
        []
    end
  end
end
