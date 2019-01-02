defmodule Romano.Shape do
  alias Romano.Sphere
  alias Romano.Material
  alias Romano.Matrix

  defstruct name: nil, transform: Romano.Matrix.identity, material: Material.new(), inverted_transform: Romano.Matrix.identity() |> Matrix.invert()
  use Accessible

  def sphere do
    %__MODULE__{name: :sphere}
  end

  def set_transform(shape, transform) do
    %{shape | transform: transform, inverted_transform: transform |> Matrix.invert()}
  end

  def normal_at(shape = %__MODULE__{name: :sphere}, point) do
    Sphere.normal_at(shape, point)
  end
end
