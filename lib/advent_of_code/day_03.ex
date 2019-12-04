defmodule AdventOfCode.Day03 do
  defmodule Point do
    defstruct x: nil, y: nil
  end

  defmodule Segment do
    defstruct from: nil, to: nil, start: nil
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
  def part1([wire1_commands, wire2_commands]) do
    crossing_points(wire(wire1_commands), wire(wire2_commands))
    |> Enum.map(fn %Point{x: x, y: y} -> abs(x) + abs(y) end)
    |> Enum.min()
  end

  defp wire(commands) do
    {_, points} =
      commands
      |> Enum.reduce({%Point{x: 0, y: 0}, []}, fn command, acc ->
        move(command, acc)
      end)

    Enum.reverse(points)
  end

  defp crossing_points(wire1, wire2) do
    MapSet.intersection(MapSet.new(wire1), MapSet.new(wire2))
  end

  defp move("R"<>quantity, acc) do
    1..String.to_integer(quantity)
    |> Enum.reduce(acc, fn _, {point, points} ->
      new_point = %Point{x: point.x + 1, y: point.y}
      {new_point, [new_point | points]}
    end)
  end

  defp move("L"<>quantity, acc) do
    1..String.to_integer(quantity)
    |> Enum.reduce(acc, fn _, {point, points} ->
      new_point = %Point{x: point.x - 1, y: point.y}
      {new_point, [new_point | points]}
    end)
  end

  defp move("D"<>quantity, acc) do
    1..String.to_integer(quantity)
    |> Enum.reduce(acc, fn _, {point, points} ->
      new_point = %Point{x: point.x, y: point.y - 1}
      {new_point, [new_point | points]}
    end)
  end

  defp move("U"<>quantity, acc) do
    1..String.to_integer(quantity)
    |> Enum.reduce(acc, fn _, {point, points} ->
      new_point = %Point{x: point.x, y: point.y + 1}
      {new_point, [new_point | points]}
    end)
  end

  @doc """
    Day 3 part 1

    ## Examples:
      iex> AdventOfCode.Day03.part2([
      iex>  ["R8","U5","L5","D3"], ["U7","R6","D4","L4"]])
      30
      iex> AdventOfCode.Day03.part2([
      iex>  ["R75","D30","R83","U83","L12","D49","R71","U7","L72"],
      iex>  ["U62","R66","U55","R34","D71","R55","D58","R83"]])
      610
      iex> AdventOfCode.Day03.part2([
      iex>  ["R98","U47","R26","D63","R33","U87","L62","D20","R33","U53","R51"],
      iex>  ["U98","R91","D20","R16","D67","R40","U7","R15","U6","R7"]])
      410
  """
  def part2([wire1_commands, wire2_commands]) do
    wire1 = wire(wire1_commands)
    wire2 = wire(wire2_commands)

    wire1_costs = calculate_costs(wire1)
    wire2_costs = calculate_costs(wire2)

    crossing_points(wire1, wire2)
    |> Enum.map(fn point -> wire1_costs[point] + wire2_costs[point] end)
    |> Enum.min()
  end

  defp calculate_costs(wire_points) do
    {_, costs} =
      wire_points
      |> Enum.reduce({0, %{}}, fn point, {current_cost, costs} ->
        {current_cost + 1, Map.put_new(costs, point, current_cost + 1)}
      end)

    costs
  end
end

