defmodule Romano.Shape do
  defstruct name: nil, transform: Romano.Matrix.identity
  def sphere do
    %__MODULE__{name: :sphere}
  end

  def set_transform(shape, transform) do
    %{shape | transform: transform}
  end
end
