defmodule Romano.Light do
  defstruct position: nil, intensity: nil

  def point_light(position, intensity) do
    %__MODULE__{position: position, intensity: intensity}
  end
end
