defmodule Romano.Ray do
  alias Romano.Intersection
  alias Romano.Matrix
  alias Romano.Shape
  defstruct origin: {0,0,0,1}, direction: {0,0,0,0}

  def new(origin, direction) do
    %__MODULE__{origin: origin, direction: direction}
  end

  def position(ray, t) do
    Romano.Tuple.add(ray.origin, Romano.Tuple.multiply(ray.direction, t))
  end

  def intersects(s, ray) do
    local_ray = transform(ray, s.inverted_transform)
    Shape.local_intersect(s, local_ray)
  end

  def intersect_world(w, ray) do
    Enum.flat_map(w.objects, fn o ->
      intersects(o, ray)
    end)
    |> Enum.sort(&(&1.t <= &2.t))
  end

  def transform(r, t) do
    new(Matrix.multiply(t, r.origin), Matrix.multiply(t, r.direction))
  end

end
