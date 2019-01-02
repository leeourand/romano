defmodule Romano.Sphere do
  alias Romano.Matrix
  import Romano.Tuple, only: [point: 3]

  def normal_at(s, p) do
    object_point = s.inverted_transform
                    |> Matrix.multiply(p)
    object_normal = Romano.Tuple.subtract(object_point, point(0, 0, 0))
    {x, y, z, _} = s.inverted_transform
                    |> Matrix.transpose()
                    |> Matrix.multiply(object_normal)
    {x, y, z, 0} |> Romano.Tuple.normalize()
  end
end
