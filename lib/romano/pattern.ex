defmodule Romano.Pattern do
  alias Romano.Color
  alias Romano.Matrix
  import Romano.Tuple, only: [x: 1, y: 1, z: 1]

  defstruct name: nil, a: nil, b: nil, transform: Matrix.identity(), inverted_transform: Matrix.identity()

  def stripe(a, b) do
    %__MODULE__{name: :stripe, a: a, b: b}
  end

  def test() do
    %__MODULE__{name: :test}
  end

  def set_transform(pattern = %__MODULE__{}, transform) do
    %{pattern | transform: transform, inverted_transform: Matrix.invert(transform)}
  end

  def pattern_at_shape(pattern, shape, world_point) do
    shape_point = Matrix.multiply(shape.inverted_transform, world_point)
    pattern_point = Matrix.multiply(pattern.inverted_transform, shape_point)
    pattern_at(pattern, pattern_point)
  end

  defp pattern_at(pattern = %__MODULE__{name: :stripe}, point) do
    r = x(point)
        |> :math.floor
        |> trunc
        |> rem(2)
    if r == 0 do
      pattern.a
    else
      pattern.b
    end
  end

  defp pattern_at(%__MODULE__{name: :test}, point) do
    Color.new(x(point), y(point), z(point))
  end
end
