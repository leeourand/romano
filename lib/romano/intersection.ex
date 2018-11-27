defmodule Romano.Intersection do
  defstruct t: nil, object: nil

  def new(t, object) do
    %__MODULE__{t: t, object: object}
  end

  def hit(intersections) do
    Enum.filter(intersections, fn intersection -> intersection.t >= 0 end)
    |> Enum.min_by(fn intersection -> intersection.t end, fn -> nil end)
  end

end
