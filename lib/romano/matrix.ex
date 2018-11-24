defmodule Romano.Matrix do
  def new(l) do
    from_list(l)
  end

  defp from_list(list, map \\ %{}, index \\ 0)
  defp from_list([], map, _index), do: map
  defp from_list([h|t], map, index) do
    map = Map.put(map, index, from_list(h))
    from_list(t, map, index + 1)
  end
  defp from_list(other, _, _), do: other

  def at(m, i, j) do
    m[i][j]
  end

  def set_at(m, i, j, v) do
    Map.put(m, i, Map.put(m[i], j, v))
  end

  def equal?(a, b) do
    a_vals = Map.values(a)
             |> Enum.map(fn m -> Map.values(m) |> Enum.map(fn x -> Float.round(x * 1.0, 3) end) end)
    b_vals = Map.values(b)
             |> Enum.map(fn m -> Map.values(m) |> Enum.map(fn x -> Float.round(x * 1.0, 3) end) end)
    a_vals == b_vals
  end

  def rows(m) do
    Enum.count(Map.keys(m))
  end

  def columns(m) do
    Enum.count(Map.keys(m[0]))
  end

  def column(m, j) do
    Enum.map(Map.values(m), fn value -> value[j] end)
  end

  def multiply(a, b) when is_tuple(b) do
    Enum.map(a, fn {_index, row} ->
      Romano.Tuple.dot(List.to_tuple(Map.values(row)), b)
    end)
    |> List.to_tuple
  end

  def multiply(a, b) do
    for i <- 0..(rows(a) - 1) do
      for j <- 0..(columns(b) - 1) do
        Romano.Tuple.dot(List.to_tuple(Map.values(a[i])), List.to_tuple(column(b, j)))
      end
    end
    |> new
  end

  def identity do
    [
      [1, 0, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 1, 0],
      [0, 0, 0, 1]
    ]
    |> new
  end

  def transpose(m) do
    Enum.map(m, fn {index, _row} ->
      column(m, index)
    end)
    |> new
  end

  def determinant(m) do
    case Enum.count(m) do
      2 ->
        m[0][0] * m[1][1] - m[0][1] * m[1][0]
      _ ->
        Enum.reduce(m[0], 0, fn {i, val}, acc ->
          acc + (val * cofactor(m, 0, i))
        end)
    end
  end

  def submatrix(m, i, j) do
    Enum.filter(m, fn {index, _row} ->
      index != i
    end)
    |> Enum.map(fn {_index, row} ->
      Map.delete(row, j) |> Map.values
    end)
    |> new
  end

  def minor(m, i, j) do
    submatrix(m, i, j)
    |> determinant
  end

  def cofactor(m, i, j) do
    submatrix(m, i, j)
    |> determinant
    |> potentially_negate(i + j)
  end

  defp potentially_negate(n, x) do
    case rem(x, 2) == 0 do
      true ->
        n
      false ->
        0 - n
    end
  end

  def invertible?(m) do
    determinant(m) != 0
  end

  def invert(m) do
    case invertible?(m) do
      true ->
        for row <- 0..Enum.count(m) - 1 do
          for col <- 0..Enum.count(m) -1 do
            cofactor(m, row, col) / determinant(m)
          end
        end
        |> new
        |> transpose
      _ ->
        {:error, "Matrix in not invertible"}
    end
  end
end
