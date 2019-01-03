defmodule Romano.Transformation do
  alias Romano.Matrix
  import Romano.Tuple, only: [subtract: 2, normalize: 1, cross: 2, x: 1, y: 1, z: 1]

  def translation(x, y, z) do
    Matrix.new([
      [1, 0, 0, x],
      [0, 1, 0, y],
      [0, 0, 1, z],
      [0, 0, 0, 1]
    ])
  end

  def scale(x, y, z) do
    Matrix.new([
      [x, 0, 0, 0],
      [0, y, 0, 0],
      [0, 0, z, 0],
      [0, 0, 0, 1]
    ])
  end

  def rotation_x(rads) do
    Matrix.new([
      [1, 0, 0, 0],
      [0, :math.cos(rads), :math.sin(rads) * -1, 0],
      [0, :math.sin(rads), :math.cos(rads), 0],
      [0, 0, 0, 1]
    ])
  end

  def rotation_y(rads) do
    Matrix.new([
      [:math.cos(rads), 0, :math.sin(rads), 0],
      [0, 1, 0, 0],
      [-:math.sin(rads), 0, :math.cos(rads), 0],
      [0, 0, 0, 1]
    ])
  end

  def rotation_z(rads) do
    Matrix.new([
      [:math.cos(rads), :math.sin(rads) * -1, 0, 0],
      [:math.sin(rads), :math.cos(rads), 0, 0],
      [0, 0, 1, 0],
      [0, 0, 0, 1]
    ])
  end

  def shearing(xy, xz, yx, yz, zx, zy) do
    Matrix.new([
      [1, xy, xz, 0],
      [yx, 1, yz, 0],
      [zx, zy, 1, 0],
      [0, 0, 0, 1]
    ])
  end

  def view_transform(from, to, up) do
    forward = subtract(to, from)
              |> normalize
    upn = normalize(up)
    left = cross(forward, upn)
    true_up = cross(left, forward)
    orientation = Matrix.new([
      [x(left), y(left), z(left), 0],
      [x(true_up), y(true_up), z(true_up), 0],
      [-x(forward), -y(forward), -z(forward), 0],
      [0, 0, 0, 1]
    ])
    t = translation(-x(from), -y(from), -z(from))
    Matrix.multiply(orientation, t)
  end
end
