defmodule Romano.Intersection do
  alias Romano.Computations
  alias Romano.Ray
  alias Romano.Shape
  defstruct t: nil, object: nil

  def new(t, object) do
    %__MODULE__{t: t, object: object}
  end

  def hit(intersections) do
    Enum.filter(intersections, fn intersection -> intersection.t >= 0 end)
    |> Enum.min_by(fn intersection -> intersection.t end, fn -> nil end)
  end

  def prepare_computations(intersection, ray) do
    point = Ray.position(ray, intersection.t)
    %Computations{
      t: intersection.t,
      object: intersection.object,
      point: point,
      eyev: Romano.Tuple.multiply(ray.direction, -1),
      normalv: Shape.normal_at(intersection.object, point)
    }
    |> determine_insidedness
  end

  defp determine_insidedness(comps) do
    if Romano.Tuple.dot(comps.normalv, comps.eyev) < 0 do
      %{comps | inside: true, normalv: Romano.Tuple.multiply(comps.normalv, -1)}
    else
      comps
    end
  end
end
