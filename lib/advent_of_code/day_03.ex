defmodule AdventOfCode.Day03 do
  defmodule Point do
    defstruct x: nil, y: nil
  end

  defmodule Segment do
    defstruct from: nil, to: nil
  end

  @doc """
    Day 3 part 1

    ## Examples:
      iex> AdventOfCode.Day03.part1([
      iex>  ["R8","U5","L5","D3"], ["U7","R6","D4","L4"]])
      6
      iex> AdventOfCode.Day03.part1([
      iex>  ["R75","D30","R83","U83","L12","D49","R71","U7","L72"],
      iex>  ["U62","R66","U55","R34","D71","R55","D58","R83"]])
      159
      iex> AdventOfCode.Day03.part1([
      iex>  ["R98","U47","R26","D63","R33","U87","L62","D20","R33","U53","R51"],
      iex>  ["U98","R91","D20","R16","D67","R40","U7","R15","U6","R7"]])
      135
  """
  def part1([wire1, wire2]) do
    for s1 <- segments(wire1), s2 <- segments(wire2) do
      crossing_point(s1, s2)
    end
    |> Enum.reject(fn x -> x == nil end)
    |> Enum.map(fn %Point{x: x, y: y} -> abs(x) + abs(y) end)
    |> Enum.min()
  end


  defp crossing_point(
    %Segment{from: %Point{x: x1, y: y}, to: %Point{x: x2, y: y}},
    %Segment{from: %Point{x: x, y: y1}, to: %Point{x: x, y: y2}}
  ) when x1 < x and x < x2 and y1 < y and y < y2 do
    %Point{x: x, y: y}
  end

  defp crossing_point(
    %Segment{from: %Point{x: x, y: y1}, to: %Point{x: x, y: y2}},
    %Segment{from: %Point{x: x1, y: y}, to: %Point{x: x2, y: y}}
  ) when x1 < x and x < x2 and y1 < y and y < y2 do
    %Point{x: x, y: y}
  end

  defp crossing_point(_, _), do: nil

  defp segments(wire) do
    {_, segments} =
      wire
      |> Enum.reduce({%Point{x: 0, y: 0}, []}, fn command, {possition, segments} ->
        {new_point, new_segment} = move(possition, command)

        {new_point, [new_segment | segments]}
      end)

    segments
  end

  defp move(point, "R"<>quantity) do
    target = %Point{x: point.x + String.to_integer(quantity), y: point.y}

    {target, %Segment{from: point, to: target}}
  end

  defp move(point, "L"<>quantity) do
    target = %Point{x: point.x - String.to_integer(quantity), y: point.y}

    {target, %Segment{from: target, to: point}}
  end

  defp move(point, "D"<>quantity) do
    target = %Point{x: point.x, y: point.y - String.to_integer(quantity)}

    {target, %Segment{from: target, to: point}}
  end

  defp move(point, "U"<>quantity) do
    target = %Point{x: point.x, y: point.y + String.to_integer(quantity)}

    {target, %Segment{from: point, to: target}}
  end

  def part2(args) do
  end
end

