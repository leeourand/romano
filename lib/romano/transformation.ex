defmodule Romano.Transformation do
  alias Romano.Matrix

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
      [0, :math.sin(rads), :math.cos(rads) * -1, 0],
      [:math.sin(rads) * -1, 0, :math.cos(rads), 0],
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
end
