defmodule Romano.World do
  alias Romano.Color
  alias Romano.Intersection
  alias Romano.Light
  alias Romano.Material
  alias Romano.Ray
  alias Romano.Shape
  alias Romano.Transformation
  import Romano.Tuple, only: [point: 3, subtract: 2, magnitude: 1, normalize: 1, multiply: 2, dot: 2]

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

  def color_at(world, ray, remaining_reflections \\ 5) do
    hit = Ray.intersect_world(world, ray)
          |> Intersection.hit
    if hit do
      comps = hit
              |> Intersection.prepare_computations(ray)
      Material.shade_hit(world, comps, remaining_reflections)
    else
      Color.new(0, 0, 0)
    end
  end

  def reflected_color(world, comps, remaining_reflections \\ 5) do
    if comps.object.material.reflective == 0 || remaining_reflections <= 0 do
      Color.new(0, 0, 0)
    else
      reflect_ray = Ray.new(comps.over_point, comps.reflectv)
      color_at(world, reflect_ray, remaining_reflections - 1)
      |> multiply(comps.object.material.reflective)
    end
  end

  def refracted_color(world, comps, remaining_refractions \\ 5) do
    n_ratio = comps.n1 / comps.n2
    cos_i = dot(comps.eyev, comps.normalv)
    sin2_t = :math.pow(n_ratio, 2) * (1 - :math.pow(cos_i, 2))

    if comps.object.material.transparency == 0 || sin2_t > 1 || remaining_refractions <= 0 do
      Color.new(0, 0, 0)
    else
      cos_t = :math.sqrt(1.0 - sin2_t)
      direction = multiply(comps.normalv, n_ratio * cos_i - cos_t)
                  |> subtract(multiply(comps.eyev, n_ratio))
      refract_ray = Ray.new(comps.under_point, direction)
      color_at(world, refract_ray, remaining_refractions - 1)
      |> Color.multiply(comps.object.material.transparency)
    end
  end

  def is_shadowed(world, point) do
    v = subtract(world.light.position, point)
    distance = magnitude(v)
    direction = normalize(v)
    r = Ray.new(point, direction)
    h = Ray.intersect_world(world, r)
        |> Intersection.hit
    h && h.t < distance
  end
end
