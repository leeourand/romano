defmodule Romano.Tuple do
  def new(x, y, z, w) do
    {x, y, z, w}
  end

  def x({x, _y, _z, _w}) do
    x
  end

  def y({_x, y, _z, _w}) do
    y
  end

  def z({_x, _y, z, _w}) do
    z
  end

  def w({_x, _y, _z, w}) do
    w
  end

  def point(x, y, z) do
    {x, y, z, 1}
  end

  def vector(x, y, z) do
    {x, y, z, 0}
  end

  def add({x1, y1, z1, w1}, {x2, y2, z2, w2}) do
    {x1 + x2, y1 + y2, z1 + z2, w1 + w2}
  end

  def subtract({x1, y1, z1, w1}, {x2, y2, z2, w2}) do
    {x1 - x2, y1 - y2, z1 - z2, w1 - w2}
  end

  def negate({x, y, z, w}) do
    {0 - x, 0 - y, 0 - z, 0 - w}
  end

  def multiply({x, y, z, w}, scalar) do
    {x * scalar, y * scalar, z * scalar, w * scalar}
  end

  def divide({x, y, z, w}, scalar) when scalar != 0 do
    {x / scalar, y / scalar, z / scalar, w / scalar}
  end

  def magnitude({x, y, z, 0}) do
    :math.sqrt(x * x + y * y + z * z)
  end

  def normalize(vector = {x, y, z, 0}) do
    magnitude = magnitude(vector)
    {x / magnitude, y / magnitude, z / magnitude, 0}
  end

  def dot({x1, y1, z1, w1}, {x2, y2, z2, w2}) do
    x1 * x2 +
    y1 * y2 +
    z1 * z2 +
    w1 * w2
  end

  def cross({x1, y1, z1, _w1}, {x2, y2, z2, _w2}) do
    {
      y1 * z2 - z1 * y2,
      z1 * x2 - x1 * z2,
      x1 * y2 - y1 * x2,
      0
    }
  end
end
