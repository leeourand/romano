defmodule Romano.Pattern do
  alias Romano.Color
  alias Romano.Matrix
  import Romano.Tuple, only: [x: 1, y: 1, z: 1, add: 2, multiply: 2, subtract: 2]

  defstruct name: nil, a: nil, b: nil, transform: Matrix.identity(), inverted_transform: Matrix.identity()

  def stripe(a, b) do
    %__MODULE__{name: :stripe, a: a, b: b}
  end

  def gradient(a, b) do
    %__MODULE__{name: :gradient, a: a, b: b}
  end

  def ring(a, b) do
    %__MODULE__{name: :ring, a: a, b: b}
  end

  def checkers(a, b) do
    %__MODULE__{name: :checkers, a: a, b: b}
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

  def pattern_at(pattern = %__MODULE__{name: :stripe}, point) do
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

  def pattern_at(gradient = %__MODULE__{name: :gradient}, point) do
    color_distance = subtract(gradient.b, gradient.a)
    fraction = x(point) - :math.floor(x(point))
    multiply(color_distance, fraction)
    |> add(gradient.a)
  end

  def pattern_at(gradient = %__MODULE__{name: :ring}, point) do
    r = :math.pow(x(point), 2) + :math.pow(z(point), 2)
        |> :math.floor
        |> trunc
        |> rem(2)
    if r == 0 do
      gradient.a
    else
      gradient.b
    end
  end

  def pattern_at(pattern = %__MODULE__{name: :checkers}, point) do
    r = :math.floor(x(point)) + :math.floor(y(point)) + :math.floor(z(point))
    |> trunc
    |> rem(2)
    if r == 0 do
      pattern.a
    else
      pattern.b
    end
  end

  def pattern_at(%__MODULE__{name: :test}, point) do
    Color.new(x(point), y(point), z(point))
  end

end
