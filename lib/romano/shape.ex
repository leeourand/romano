defmodule Romano.Shape do
  alias Romano.Plane
  alias Romano.Sphere
  alias Romano.Material
  alias Romano.Matrix

  defstruct name: nil, transform: Romano.Matrix.identity, material: Material.new(), inverted_transform: Romano.Matrix.identity() |> Matrix.invert()
  use Accessible

  def test do
    %__MODULE__{name: :test}
  end

  def sphere do
    %__MODULE__{name: :sphere}
  end

  def plane do
    %__MODULE__{name: :plane}
  end

  def set_transform(shape, transform) do
    %{shape | transform: transform, inverted_transform: transform |> Matrix.invert()}
  end

  def set_material(shape, material) do
    %{shape | material: material}
  end

  def normal_at(shape = %__MODULE__{}, point) do
    local_point = shape.inverted_transform
                  |> Matrix.multiply(point)
    local_normal = local_normal_at(shape, local_point)
    {x, y, z, _} = shape.inverted_transform
                    |> Matrix.transpose()
                    |> Matrix.multiply(local_normal)
    {x, y, z, 0} |> Romano.Tuple.normalize()
  end

  def local_normal_at(shape = %__MODULE__{name: :sphere}, local_point) do
    Sphere.local_normal_at(shape, local_point)
  end

  def local_normal_at(shape = %__MODULE__{name: :plane}, local_point) do
    Plane.local_normal_at(shape, local_point)
  end

  def local_normal_at(%__MODULE__{name: :test}, local_point) do
    {x, y, z, _} = local_point
    {x, y, z, 0}
  end

  def local_intersect(shape = %__MODULE__{name: :sphere}, ray) do
    Sphere.local_intersect(shape, ray)
  end

  def local_intersect(shape = %__MODULE__{name: :plane}, ray) do
    Plane.local_intersect(shape, ray)
  end

  def local_intersect(%__MODULE__{name: :test}, ray) do
    ray
  end
end
