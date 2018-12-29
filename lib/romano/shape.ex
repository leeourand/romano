defmodule Romano.Shape do
  alias Romano.Sphere
  alias Romano.Material
  defstruct name: nil, transform: Romano.Matrix.identity, material: Material.new()
  use Accessible

  def sphere do
    %__MODULE__{name: :sphere}
  end

  def set_transform(shape, transform) do
    %{shape | transform: transform}
  end

  def normal_at(shape = %__MODULE__{name: :sphere}, point) do
    Sphere.normal_at(shape, point)
  end
end
