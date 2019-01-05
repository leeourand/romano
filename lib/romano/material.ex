defmodule Romano.Material do
  alias Romano.Color
  alias Romano.Pattern
  alias Romano.Tuple
  alias Romano.World
  alias Romano.Intersection
  defstruct color: Color.new(1, 1, 1),
    ambient: 0.1,
    diffuse: 0.9,
    specular: 0.9,
    shininess: 200,
    pattern: nil,
    reflective: 0.0,
    transparency: 0.0,
    refractive_index: 1.0
  use Accessible

  def new do
    %__MODULE__{}
  end

  def lighting(material, object, light, point, eyev, normalv, in_shadow) do
    color = if material.pattern do
      Pattern.pattern_at_shape(material.pattern, object, point)
    else
      material.color
    end

    effective_color = Color.multiply(color, light.intensity)
    lightv = Tuple.subtract(light.position, point)
              |> Tuple.normalize()
    ambient = Color.multiply(effective_color, material.ambient)
    light_dot_normal = Tuple.dot(lightv, normalv)
    diffuse = calc_diffuse(light_dot_normal, material.diffuse, effective_color)
    reflectv = Tuple.multiply(lightv, -1.0)
                |> Tuple.reflect(normalv)
    reflect_dot_eye = Tuple.dot(reflectv, eyev)
    specular = calc_specular(light_dot_normal, reflect_dot_eye, material, light)
    if in_shadow do
      ambient
    else
      Color.add(ambient, diffuse)
      |> Color.add(specular)
    end
  end

  def shade_hit(world, comps, remaining_reflections \\ 5) do
    shadowed = World.is_shadowed(world, comps.over_point)
    surface = lighting(comps.object.material, comps.object, world.light, comps.over_point, comps.eyev, comps.normalv, shadowed)
    reflected = World.reflected_color(world, comps, remaining_reflections)
    refracted = World.refracted_color(world, comps, remaining_reflections)
    material = comps.object.material

    if material.reflective > 0 && material.transparency > 0 do
      reflectance = Intersection.schlick(comps)
      Color.multiply(reflected, reflectance)
      |> Color.add(Color.multiply(refracted, 1 - reflectance))
      |> Color.add(surface)
    else
      Color.add(surface, reflected)
      |> Color.add(refracted)
    end
  end

  defp calc_diffuse(light_dot_normal, _material_diffuse, _effective_color) when light_dot_normal < 0 do
    Color.new(0, 0, 0)
  end

  defp calc_diffuse(light_dot_normal, material_diffuse, effective_color) do
    Color.multiply(effective_color, material_diffuse)
    |> Color.multiply(light_dot_normal)
  end

  defp calc_specular(light_dot_normal, _reflect_dot_eye, _material, _light) when light_dot_normal < 0 do
    Color.new(0, 0, 0)
  end

  defp calc_specular(_light_dot_normal, reflect_dot_eye, _material, _light) when reflect_dot_eye <= 0 do
    Color.new(0, 0, 0)
  end

  defp calc_specular(_light_dot_normal, reflect_dot_eye, material, light) do
    factor = :math.pow(reflect_dot_eye, material.shininess)
    Color.multiply(light.intensity, material.specular)
    |> Color.multiply(factor)
  end
end
