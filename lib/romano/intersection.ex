defmodule Romano.Intersection do
  alias Romano.Computations
  alias Romano.Ray
  alias Romano.Shape
  import Romano.Tuple, only: [add: 2, subtract: 2, multiply: 2, dot: 2]
  defstruct t: nil, object: nil

  def new(t, object) do
    %__MODULE__{t: t, object: object}
  end

  def hit(intersections) do
    Enum.filter(intersections, fn intersection -> intersection.t >= 0 end)
    |> Enum.min_by(fn intersection -> intersection.t end, fn -> nil end)
  end

  def prepare_computations(intersection, ray, intersections \\ nil) do
    intersections = intersections || [intersection]
    point = Ray.position(ray, intersection.t)
    normalv = Shape.normal_at(intersection.object, point)
    %Computations{
      t: intersection.t,
      object: intersection.object,
      point: point,
      over_point: multiply(normalv, Romano.epsilon()) |> add(point),
      under_point: subtract(point, multiply(normalv, Romano.epsilon())),
      eyev: Romano.Tuple.multiply(ray.direction, -1),
      normalv: normalv
    }
    |> determine_insidedness
    |> determine_reflection(ray)
    |> determine_n1_and_n2(intersection, intersections)
  end

  defp determine_insidedness(comps) do
    if Romano.Tuple.dot(comps.normalv, comps.eyev) < 0 do
      normalv = multiply(comps.normalv, -1)
      %{comps |
        inside: true,
        normalv: normalv,
        over_point: multiply(normalv, Romano.epsilon()) |> add(comps.point),
        under_point: subtract(comps.point, multiply(normalv, Romano.epsilon()))
      }
    else
      comps
    end
  end

  defp determine_reflection(comps, ray) do
    %{comps | reflectv: Romano.Tuple.reflect(ray.direction, comps.normalv)}
  end

  defp determine_n1_and_n2(comps, hit, xs) do
    {_, n1, n2} = Enum.reduce(xs, {[], nil, nil}, fn intersection, {containers, n1, n2} ->
      new_n1 = if intersection == hit do
        if Enum.empty?(containers) do
          1.0
        else
          List.last(containers).material.refractive_index
        end
      end

      containers = if Enum.member?(containers, intersection.object) do
        List.delete(containers, intersection.object)
      else
        List.insert_at(containers, -1, intersection.object)
      end

      n2 = n2 || if intersection == hit do
        if Enum.empty?(containers) do
          1.0
        else
          List.last(containers).material.refractive_index
        end
      end
      {containers, new_n1 || n1, n2}
    end)

    %{comps | n1: n1, n2: n2}
  end

  def schlick(comps) do
    cos = dot(comps.eyev, comps.normalv)
    if comps.n1 > comps.n2 do
      n = comps.n1 / comps.n2
      sin2_t = :math.pow(n, 2) * (1.0 - :math.pow(cos, 2))
      if sin2_t > 1 do
        1.0
      else
        cos = :math.sqrt(1.0 - sin2_t)
        schlick_formula(comps.n1, comps.n2, cos)
      end
    else
      schlick_formula(comps.n1, comps.n2, cos)
    end
  end

  defp schlick_formula(n1, n2, cos) do
    r0 = :math.pow(((n1 - n2) / (n1 + n2)), 2)
    r0 + (1 - r0) * :math.pow(1 - cos, 5)
  end
end
