defmodule AdventOfCode.Day11 do
  def part1(code) do
    code |> paint(0) |> Enum.count()
  end

  def part2(code) do
    map = code |> paint(1)
    {{min_x, min_y}, {max_x, max_y}} = map |> min_max()

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        case Map.get(map, {x, y}, 0) do
          0 -> ' '
          1 -> ?#
        end
      end
    end
    |> Enum.intersperse(?\n)
    |> IO.puts()
  end

  defp min_max(map) do
    map
    |> Enum.reduce({{0, 0}, {0, 0}}, fn {{x, y}, _}, {{min_x, min_y}, {max_x, max_y}} ->
      {{min(x, min_x), min(y, min_y)}, {max(x, max_x), max(y, max_y)}}
    end)
  end

  defp paint(code, color) do
    my_pid = self()
    pid = spawn(fn -> AdventOfCode.Intcode.run(code, my_pid) end)

    send(pid, {:input, color})
    paint_loop(pid, {0, 0}, ?^, %{})
  end

  defp paint_loop(pid, position, facing, map) do
    receive do
      {:output, color} ->
        rotate_move_and_repeat(pid, position, facing, Map.put(map, position, color))

      :eot ->
        map
    end
  end

  defp rotate_move_and_repeat(pid, position, facing, map) do
    receive do
      {:output, rotation} ->
        new_facing = rotate(facing, rotation)
        new_position = move(position, new_facing)

        send(pid, {:input, Map.get(map, new_position, 0)})
        paint_loop(pid, new_position, new_facing, map)

      :eot ->
        map
    end
  end

  defp rotate(?^, 0), do: ?<
  defp rotate(?<, 0), do: ?v
  defp rotate(?v, 0), do: ?>
  defp rotate(?>, 0), do: ?^
  defp rotate(?^, 1), do: ?>
  defp rotate(?>, 1), do: ?v
  defp rotate(?v, 1), do: ?<
  defp rotate(?<, 1), do: ?^

  defp move({x, y}, ?^), do: {x, y + 1}
  defp move({x, y}, ?v), do: {x, y - 1}
  defp move({x, y}, ?>), do: {x + 1, y}
  defp move({x, y}, ?<), do: {x - 1, y}
end
