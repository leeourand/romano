defmodule Romano.Shape do
  alias Romano.Material
  defstruct name: nil, transform: Romano.Matrix.identity, material: Material.new()

  def sphere do
    %__MODULE__{name: :sphere}
  end

  def set_transform(shape, transform) do
    %{shape | transform: transform}
  end
end
