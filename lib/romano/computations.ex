defmodule Romano.Computations do
  defstruct t: nil,
    object: nil,
    point: nil,
    over_point: nil,
    eyev: nil,
    normalv: nil,
    inside: false,
    reflectv: nil,
    n1: nil,
    n2: nil,
    under_point: nil
  use Accessible
end
