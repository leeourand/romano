defmodule Romano.Intersection do
  alias Romano.Computations
  alias Romano.Ray
  alias Romano.Shape
  import Romano.Tuple, only: [add: 2, multiply: 2]
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
    normalv = Shape.normal_at(intersection.object, point)
    %Computations{
      t: intersection.t,
      object: intersection.object,
      point: point,
      over_point: multiply(normalv, Romano.epsilon()) |> add(point),
      eyev: Romano.Tuple.multiply(ray.direction, -1),
      normalv: normalv
    }
    |> determine_insidedness
  end

  defp determine_insidedness(comps) do
    if Romano.Tuple.dot(comps.normalv, comps.eyev) < 0 do
      normalv = multiply(comps.normalv, -1)
      %{comps |
        inside: true,
        normalv: normalv,
        over_point: multiply(normalv, Romano.epsilon()) |> add(comps.point)
      }
    else
      comps
    end
  end
end
