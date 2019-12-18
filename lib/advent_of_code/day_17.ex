defmodule AdventOfCode.Day17 do
  def part1(code) do
    code
    |> build_map()
    |> print()
    |> find_intersections()
    |> Enum.reduce(0, fn {x, y}, sum -> sum + x * y end)
  end

  defp build_map(code) do
    initial_state = AdventOfCode.Intcode.parse(code)

    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while({{0, 0}, %{}, initial_state}, fn _, {{x, y}, map, state} ->
      case AdventOfCode.Intcode.run(state) do
        {:output, new_state, output} ->
          case output do
            ?\n -> {:cont, {{0, y + 1}, map, new_state}}
            v   -> {:cont, {{x + 1, y}, Map.put(map, {x, y}, v), new_state}}
          end

        {:input_required, new_state} -> {:halt, {map, new_state}}

        {:eot, _} -> {:halt, map}
      end
    end)
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
        Map.get(map, {x, y}, ?.)
      end
    end
    |> Enum.intersperse(?\n)
    |> IO.puts()

    map
  end

  def part2([_ | code]) do
    {map, state} = [2 | code]|> build_map()
    print(map)

    commands =
      Stream.iterate(1, &(&1 + 1))
      |> Enum.reduce_while({find_vacuum(map), []}, fn _, {{{x, y}, direction} = vacuum, actions} ->
        case find_move(map, vacuum) do
          nil -> {:halt, Enum.reverse(actions)}
          {action, new_direction} ->
            {new_x, new_y} = find_edge(map, {x, y}, new_direction)
            distance = abs(new_x - x) + abs(new_y - y)
            {:cont, {{{new_x, new_y}, new_direction}, [distance, action | actions]}}
        end
      end)

    commands |> find_patterns()
    # commands |> List.to_string()

    # |> Enum.map(fn x ->
    #   if x < ?A, do: Integer.to_string(x) <> " ", else: <<x::utf8>>
    #  end)
    #  |> Enum.join("")

    # {?A, [?R, 10, ?R, 10, ?R, 6, ?R, 4, ?R, 10, ?R, 10, ?L,4]}
    # {?B, [?R, 10, ?R, 10, ?R, 6, ?R, 4, ?R, 4, ?L, 4, ?L, 10, ?L, 10]}
    # {?A, [?R, 10, ?R, 10, ?R, 6, ?R, 4, ?R, 10, ?R, 10, ?L, 4]}
    # {?C, [?R, 4, ?L, 4, ?L, 10, ?L, 10, ?R, 10, ?R, 10, ?L, 4]}
    # {?C, [?R, 4, ?L, 4, ?L, 10, ?L, 10, ?R, 10, ?R, 10, ?L, 4]}

    # %{code: code} = initial_state = AdventOfCode.Intcode.parse(code)
    # {:input, initial_state} = AdventOfCode.Intcode.run(%{initial_state | code: Map.put(code, 0, 2)})
    #
    # [?A, ?,, ?B, ?,, ?A, ?,, ?C, ?,, ?C, ?\n,
    #  ?R, ?,, 10, ?,, ?R, ?,, 10, ?,, ?R, ?,, 6, ?,, ?R, ?,, 4, ?,, ?R, ?,, 10, ?,, ?R, ?,, 10, ?,, ?L, ?,, 4, ?\n, #A
    #  ?R, ?,, 10, ?,, ?R, ?,, 10, ?,, ?R, ?,, 6, ?,, ?R, ?,, 4, ?,, ?R, ?,, 4, ?,, ?L, ?,, 4, ?,, ?L, ?,, 10, ?,, ?L, ?,, 10, ?,, ?\n, #B
    #  ?R, ?,, 4, ?,, ?L, ?,, 4, ?,, ?L, ?,, 10, ?,, ?L, ?,, 10, ?,, ?R, ?,, 10, ?,, ?R, ?,, 10, ?,, ?L, ?,, 4, ?,, ?\n] #c
    # |> Enum.reduce(initial_state, fn command, state ->
    #   {:input, new_state} = AdventOfCode.Intcode.run(%{state | input: command})
    #   new_state
    # end)
  end

  defp find_patterns(commands) do
    commands |> find_pattern()
  end

  defp find_pattern(commands, split_index \\ 20) do
    {candidate, rest} = Enum.split(commands, split_index)

    case String.split(List.to_string(rest), List.to_string(candidate)) do
      [_] -> find_pattern(commands, split_index - 2)
      result -> {candidate, result, split_index}
    end
  end

  defp find_edge(map, vacuum_location, direction) do
    {d_x, d_y} = diff(direction)

    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(vacuum_location, fn _, {x, y} ->
      new_point = {x + d_x, y + d_y}
      case Map.get(map, new_point) do
        ?# -> {:cont, new_point}
        _  -> {:halt, {x, y}}
      end
    end)
  end

  defp diff(?^), do: {0, -1}
  defp diff(?>), do: {1, 0}
  defp diff(?v), do: {0, 1}
  defp diff(?<), do: {-1, 0}

  defp find_vacuum(map) do
    map
    |> Enum.find(fn {_, t} -> t == ?^ or t == ?> or t == ?v or t == ?< end)
  end

  def find_move(map, {{x, y}, current_direction}) do
    cond do
      current_direction == ?^ or current_direction == ?v ->
        cond do
          Map.get(map, {x - 1, y}) == ?# ->
            {move(current_direction, ?<), ?<}

          Map.get(map, {x + 1, y}) == ?# ->
            {move(current_direction, ?>), ?>}

          true -> nil
        end
      true ->
        cond do
          Map.get(map, {x, y - 1}) == ?# ->
            {move(current_direction, ?^), ?^}

          Map.get(map, {x, y + 1}) == ?# ->
            {move(current_direction, ?v), ?v}

          true -> nil
        end
    end
  end

  defp move(?^, ?>), do: ?R
  defp move(?^, ?<), do: ?L

  defp move(?>, ?v), do: ?R
  defp move(?>, ?^), do: ?L

  defp move(?v, ?<), do: ?R
  defp move(?v, ?>), do: ?L

  defp move(?<, ?^), do: ?R
  defp move(?<, ?v), do: ?L
end
