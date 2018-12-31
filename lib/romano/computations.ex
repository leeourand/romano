defmodule Romano.Computations do
  defstruct t: nil,
    object: nil,
    point: nil,
    over_point: nil,
    eyev: nil,
    normalv: nil,
    inside: false
  use Accessible
end
