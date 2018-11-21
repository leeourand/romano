defmodule Romano.Color do
  defstruct red: 0, green: 0, blue: 0

  def new(r, g, b) do
    {r, g, b}
  end

  def add(c1, c2) do
    Romano.Tuple.add(c1, c2)
  end

  def subtract(c1, c2) do
    Romano.Tuple.subtract(c1, c2)
  end

  def multiply(c1, scalar) when is_number(scalar) do
    Romano.Tuple.multiply(c1, scalar)
  end

  def multiply({r1, g1, b1}, {r2, g2, b2}) do
    {r1 * r2, g1 * g2, b1 * b2}
  end

  def red({r, _g, _b}) do
    r
  end

  def green({_r, g, _b}) do
    g
  end

  def blue({_r, _g, b}) do
    b
  end
end
