defmodule Romano.Plane do
  alias Romano.Intersection
  alias Romano.Shape
  import Romano.Tuple, only: [vector: 3]

  def local_normal_at(_plane = %Shape{name: :plane}, _point) do
    vector(0, 1, 0)
  end

  def local_intersect(plane = %Shape{name: :plane}, ray) do
    if abs(Romano.Tuple.y(ray.direction)) < Romano.epsilon() do
      []
    else
      t = -Romano.Tuple.y(ray.origin) / Romano.Tuple.y(ray.direction)
      [Intersection.new(t, plane)]
    end
  end
end
