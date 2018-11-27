defmodule MatrixTest do
  use ExUnit.Case
  alias Romano.Matrix

  test "creating a matrix" do
    m = Matrix.new([
      [1, 2, 3, 4],
      [5.5, 6.5, 7.5, 8.5],
      [9, 10, 11, 12],
      [13.5, 14.5, 15.5, 16.5]
    ])
    assert Matrix.at(m, 0, 0) == 1
    assert Matrix.at(m, 0, 3) == 4
    assert Matrix.at(m, 3, 0) == 13.5
  end

  test "setting values" do
    m = Matrix.new([
      [0,0,0],
      [0,0,0]
    ])
    |> Matrix.set_at(1, 1, -4)

    assert Matrix.at(m, 1, 1) == -4
  end

  test "matrix equality" do
    a = Matrix.new([
      [1, 2, 3],
      [4, 5, 6]
    ])
    b = Matrix.new([
      [1, 2.0000001, 3],
      [4, 5, 6]
    ])
    c = Matrix.new([
      [2, 3, 4],
      [5, 6, 7]
    ])
    assert Matrix.equal?(a, b)
    refute Matrix.equal?(a, c)
  end

  test "row counts" do
    count = Matrix.new([
      [1, 2, 3],
      [4, 5, 6]
    ])
    |> Matrix.rows
    assert count == 2
  end

  test "column counts" do
    count = Matrix.new([
      [1, 2, 3],
      [4, 5, 6]
    ])
    |> Matrix.columns
    assert count == 3
  end

  test "column contents" do
    m = Matrix.new([
      [1, 2, 3],
      [4, 5, 6]
    ])
    assert Matrix.column(m, 0) == [1, 4]
    assert Matrix.column(m, 1) == [2, 5]
    assert Matrix.column(m, 2) == [3, 6]
  end

  test "multiplying two matrices" do
    a = Matrix.new([
      [1, 2, 3, 4],
      [5, 6, 7, 8],
      [9, 8, 7, 6],
      [5, 4, 3, 2]
    ])
    b = Matrix.new([
      [-2, 1, 2, 3],
      [3, 2, 1, -1],
      [4, 3, 6, 5],
      [1, 2, 7, 8]
    ])
    assert Matrix.multiply(a, b) == Matrix.new([
      [20, 22, 50, 48],
      [44, 54, 114, 108],
      [40, 58, 110, 102],
      [16, 26, 46, 42]
    ])
  end

  test "multiplying a matrix with a vector" do
    a = Matrix.new([
      [1, 2, 3, 4],
      [2, 4, 4, 2],
      [8, 6, 4, 1],
      [0, 0, 0, 1]
    ])

    v = Romano.Tuple.new(1,2,3,1)
    assert Matrix.multiply(a, v) == Romano.Tuple.new(18, 24, 33, 1)
  end

  test "the identity matrix" do
    a = Matrix.new([
      [1, 2, 3, 4],
      [5, 6, 7, 8],
      [8, 7, 6, 5],
      [4, 3, 2, 1]
    ])
    assert Matrix.multiply(a, Matrix.identity) == a
  end

  test "transposing" do
    a = Matrix.new([
      [1, 2, 3, 4],
      [5, 6, 7, 8],
      [8, 7, 6, 5],
      [4, 3, 2, 1]
    ])

    assert Matrix.transpose(a) == Matrix.new([
      [1, 5, 8, 4],
      [2, 6, 7, 3],
      [3, 7, 6, 2],
      [4, 8, 5, 1]
    ])
  end

  test "finding the determinant of a 2x2 matrix" do
    a = Matrix.new([
      [1, 5],
      [-3, 2]
    ])

    assert Matrix.determinant(a) == 17
  end

  test "submatrices" do
    a = Matrix.new([
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9]
    ])

    assert Matrix.submatrix(a, 0, 2) == Matrix.new([
      [4, 5],
      [7, 8]
    ])

    a = Matrix.new([
      [1, 2, 3, 5],
      [4, 5, 6, 8],
      [7, 8, 9, 10],
      [9, 8, 7, 6]
    ])

    assert Matrix.submatrix(a, 0, 2) == Matrix.new([
      [4, 5, 8],
      [7, 8, 10],
      [9, 8, 6]
    ])
  end

  test "the minor of a 3x3 matrix" do
    a = Matrix.new([
      [3, 5, 0],
      [2, -1, -7],
      [6, -1, 5]
    ])

    assert Matrix.minor(a, 1, 0) == 25
  end

  test "the cofactor of a 3x3 matrix" do
    a = Matrix.new([
      [3, 5, 0],
      [2, -1, -7],
      [6, -1, 5]
    ])

    assert Matrix.minor(a, 0, 0) == -12
    assert Matrix.cofactor(a, 0, 0) == -12
    assert Matrix.minor(a, 1, 0) == 25
    assert Matrix.cofactor(a, 1, 0) == -25
  end

  test "finding the determinant of a 3x3 matrix" do
    a = Matrix.new([
      [1, 2, 6],
      [-5, 8, -4],
      [2, 6, 4]
    ])

    assert Matrix.cofactor(a, 0, 0) == 56
    assert Matrix.cofactor(a, 0, 1) == 12
    assert Matrix.cofactor(a, 0, 2) == -46
    assert Matrix.determinant(a) == -196
  end

  test "finding the determinant of a 4x4 matrix" do
    a = Matrix.new([
      [-2, -8, 3, 5],
      [-3, 1, 7, 3],
      [1, 2, -9, 6],
      [-6, 7, 7, -9]
    ])

    assert Matrix.cofactor(a, 0, 0) == 690
    assert Matrix.cofactor(a, 0, 1) == 447
    assert Matrix.cofactor(a, 0, 2) == 210
    assert Matrix.cofactor(a, 0, 3) == 51
    assert Matrix.determinant(a) == -4071
  end

  test "determining invertibility" do
    a = Matrix.new([
      [6, 4, 4, 4],
      [5, 5, 7, 6],
      [4, -9, 3, -7],
      [9, 1, 7, -6]
    ])

    assert Matrix.determinant(a) == -2120
    assert Matrix.invertible?(a)

    b = Matrix.new([
      [-4, 2, -2, -3],
      [9, 6, 2, 6],
      [0, -5, 1, -5],
      [0, 0, 0, 0]
    ])

    assert Matrix.determinant(b) == 0
    refute Matrix.invertible?(b)
  end

  test "inversion" do
    a = Matrix.new([
      [-5, 2, 6, -8],
      [1, -5, 1, 8],
      [7, 7, -6, -7],
      [1, -3, 7, 4]
    ])
    assert Matrix.equal?(Matrix.invert(a), Matrix.new([
      [0.21805, 0.45113, 0.24060, -0.04511],
      [-0.80827, -1.45677, -0.44361, 0.52068],
      [-0.07895, -0.22368, -0.05263, 0.19737],
      [-0.52256, -0.81391, -0.30075, 0.30639]
    ]))

    b = Matrix.new([
      [8, -5, 9, 2],
      [7, 5, 6, 1],
      [-6, 0, 9, 6],
      [-3, 0, -9, -4]
    ])
    assert Matrix.equal?(Matrix.invert(b), Matrix.new([
      [-0.15385, -0.15385, -0.28205, -0.53846],
      [-0.07692, 0.12308, 0.02564, 0.03077],
      [0.35897, 0.35897, 0.43590, 0.92308],
      [-0.69231, -0.69231, -0.76923, -1.92308]
    ]))

    a = Matrix.new([
      [3, -9, 7, 3],
      [3, -8, 2, -9],
      [-4, 4, 4, 1],
      [-6, 5, -1, 1]
    ])

    b = Matrix.new([
      [8, 2, 2, 2],
      [3, -1, 7, 0],
      [7, 0, 5, 4],
      [6, -2, 0, 5]
    ])

    c = Matrix.multiply(a, b)

    new_a = Matrix.invert(b)
    |> Matrix.multiply(c)

    Matrix.equal?(new_a, a)
  end
end
