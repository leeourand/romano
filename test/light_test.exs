defmodule LightTest do
  use ExUnit.Case, async: true
  alias Romano.Color
  alias Romano.Light
  import Romano.Tuple, only: [point: 3]

  test "a point light has a position and intensity" do
    position = point(0, 0, 0)
    intensity = Color.new(1, 1, 1)
    light = Light.point_light(position, intensity)
    assert light.position == position
    assert light.intensity == intensity
  end
end
