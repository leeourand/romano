defmodule Romano.Canvas do
  alias Romano.Color
  defstruct width: 0, height: 0, pixels: %{}, default_color: Color.new(0,0,0)

  def new(width, height) do
    %__MODULE__{width: width, height: height}
  end

  def write_pixel(canvas = %__MODULE__{}, coords, color) do
    %__MODULE__{canvas | pixels: Map.put(canvas.pixels, coords, color)}
  end

  def pixel_at(canvas = %__MODULE__{}, coord) do
    Map.get(canvas.pixels, coord, canvas.default_color)
  end

  def to_ppm(canvas = %__MODULE__{}) do
    header = "P3\n#{canvas.width} #{canvas.height}\n255"
    body = for y <- 0..(canvas.height - 1) do
      for x <- 0..(canvas.width - 1) do
        pixel_at(canvas, {x, y})
          |> Tuple.to_list
          |> Enum.map(fn x -> clamp_color_component(x) end)
          |> Enum.join(" ")
      end
      |> Enum.join(" ")
    end
    |> Enum.join("\n")
    Enum.join([header,body, "\n"], "\n")
  end

  defp clamp_color_component(c) do
    max = Enum.max([c * 255, 0])
    Enum.min([Kernel.round(max), 255])
  end
end
