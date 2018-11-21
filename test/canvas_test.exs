defmodule CanvasTest do
  use ExUnit.Case
  alias Romano.Canvas
  alias Romano.Color

  test "creating a canvas" do
    c = Canvas.new(10, 20)
    assert c.width == 10
    assert c.height == 20
  end

  test "drawing pixels" do
    c = Canvas.new(10, 10)
    red = Color.new(1, 0, 0)
    c = Canvas.write_pixel(c, {2, 3}, red)
    assert Canvas.pixel_at(c, {2, 3}) == red
  end

  test "exporting to ppm" do
    color1 = Color.new(1.5, 0, 0)
    color2 = Color.new(0, 0.5, 0)
    color3 = Color.new(-0.5, 0, 1)
    ppm = Canvas.new(5, 3)
        |> Canvas.write_pixel({0, 0}, color1)
        |> Canvas.write_pixel({2, 1}, color2)
        |> Canvas.write_pixel({4, 2}, color3)
        |> Canvas.to_ppm

    strs = String.split(ppm, "\n")
    assert Enum.at(strs, 0) == "P3"
    assert Enum.at(strs, 1) == "5 3"
    assert Enum.at(strs, 2) == "255"
    assert Enum.at(strs, 3) == "255 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
    assert Enum.at(strs, 4) == "0 0 0 0 0 0 0 128 0 0 0 0 0 0 0"
    assert Enum.at(strs, 5) == "0 0 0 0 0 0 0 0 0 0 0 0 0 0 255"
    assert Enum.at(strs, 6) == ""
  end
end
