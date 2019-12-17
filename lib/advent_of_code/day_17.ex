defmodule AdventOfCode.Day17 do
  def part1(code) do
    initial_state = AdventOfCode.Intcode.parse(code)

    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while({{0, 0}, %{}, initial_state}, fn _, {{x, y}, map, state} ->
      case AdventOfCode.Intcode.run(state) do
        {:output, new_state, output} ->
          case output do
            ?\n -> {:cont, {{0, y + 1}, map, new_state}}
            v   -> {:cont, {{x + 1, y}, Map.put(map, {x, y}, v), new_state}}
          end

        {:eot, _} -> {:halt, map}
      end
    end)
    |> print()
    |> find_intersections()
    |> Enum.reduce(0, fn {x, y}, sum -> sum + x * y end)
  end

  defp find_intersections(map) do
    {{max_x, max_y}, _} = Enum.max(map)

    for y <- 1..(max_y - 1),  x <- 1..(max_x - 1), intersection?(map, {x, y}), do: {x, y}
  end

  defp intersection?(map, {x, y}) do
    Map.get(map, {x, y}) == ?# and
    Map.get(map, {x - 1, y}) == ?# and
    Map.get(map, {x, y - 1}) == ?# and
    Map.get(map, {x + 1, y}) == ?# and
    Map.get(map, {x, y + 1}) == ?#
  end

  defp print(map) do
    {{max_x, max_y}, _} = Enum.max(map)

    for y <- 0..max_y do
      for x <- 0..max_x do
        case intersection?(map, {x, y}) do
          true -> ?O
          false -> Map.get(map, {x, y}, ?.)
        end
      end
    end
    |> Enum.intersperse(?\n)
    |> IO.puts()

    map
  end

  def part2(args) do
  end
end
