defmodule Romano.World do
  alias Romano.Color
  alias Romano.Intersection
  alias Romano.Light
  alias Romano.Material
  alias Romano.Ray
  alias Romano.Shape
  alias Romano.Transformation
  import Romano.Tuple, only: [point: 3]

  defstruct objects: [], light: nil
  use Accessible

  def new do
    %__MODULE__{}
  end

  def default do
    d = put_in(new().light, Light.point_light(point(-10, 10, -10), Color.new(1, 1, 1)))
    %{d | objects: default_spheres()}
  end

  defp default_spheres do
    shape1 = put_in(Shape.sphere().material.color, Color.new(0.8, 1, 0.6))
              |> put_in([Access.key!(:material), Access.key!(:diffuse)], 0.7)
              |> put_in([Access.key!(:material), Access.key!(:specular)], 0.2)
    shape2 = Shape.sphere()
              |> Shape.set_transform(Transformation.scale(0.5, 0.5, 0.5))
    [shape1, shape2]
  end

  def color_at(world, ray) do
    intersections = Ray.intersect_world(world, ray)
    if Enum.count(intersections) == 0 do
      Color.new(0, 0, 0)
    else
      comps = intersections
              |> Intersection.hit
              |> Intersection.prepare_computations(ray)
      Material.shade_hit(world, comps)
    end
  end
end
