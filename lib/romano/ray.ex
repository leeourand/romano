defmodule Romano.Ray do
  alias Romano.Intersection
  alias Romano.Matrix
  defstruct origin: {0,0,0,1}, direction: {0,0,0,0}

  def new(origin, direction) do
    %__MODULE__{origin: origin, direction: direction}
  end

  def position(ray, t) do
    Romano.Tuple.add(ray.origin, Romano.Tuple.multiply(ray.direction, t))
  end

  def intersects(s, ray) do
    ray = transform(ray, Matrix.invert(s.transform))
    center_to_ray = Romano.Tuple.subtract(ray.origin, Romano.Tuple.point(0,0,0))
    a = Romano.Tuple.dot(ray.direction, ray.direction)
    b = 2.0 * Romano.Tuple.dot(ray.direction, center_to_ray)
    c = Romano.Tuple.dot(center_to_ray, center_to_ray) - 1
    discriminant = b * b - 4 * a * c
    case discriminant >= 0 do
      true ->
        [
          Intersection.new(((b * -1.0 - :math.sqrt(discriminant)) / (2 * a)), s),
          Intersection.new(((b * -1.0 + :math.sqrt(discriminant)) / (2 * a)), s)
        ]
      false ->
        []
    end
  end

  def transform(r, t) do
    new(Matrix.multiply(t, r.origin), Matrix.multiply(t, r.direction))
  end

end
