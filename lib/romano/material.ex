defmodule Romano.Material do
  alias Romano.Color
  alias Romano.Tuple
  defstruct color: Color.new(1, 1, 1), ambient: 0.1, diffuse: 0.9, specular: 0.9, shininess: 200

  def new do
    %__MODULE__{}
  end

  def lighting(material, light, point, eyev, normalv) do
    effective_color = Color.multiply(material.color, light.intensity)
    lightv = Tuple.subtract(light.position, point)
              |> Tuple.normalize()
    ambient = Color.multiply(effective_color, material.ambient)
    light_dot_normal = Tuple.dot(lightv, normalv)
    diffuse = calc_diffuse(light_dot_normal, material.diffuse, effective_color)
    reflectv = Tuple.multiply(lightv, -1.0)
                |> Tuple.reflect(normalv)
    reflect_dot_eye = Tuple.dot(reflectv, eyev)
    specular = calc_specular(light_dot_normal, reflect_dot_eye, material, light)
    Color.add(ambient, diffuse)
    |> Color.add(specular)
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

  defp calc_specular(light_dot_normal, reflect_dot_eye, material, light) do
    factor = :math.pow(reflect_dot_eye, material.shininess)
    specular = Color.multiply(light.intensity, material.specular)
                |> Color.multiply(factor)
  end
end
