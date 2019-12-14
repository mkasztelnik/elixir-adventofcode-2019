defmodule AdventOfCode.Day13 do
  def part1(code) do
    my_pid = self()
    pid = spawn(fn -> AdventOfCode.Intcode.run(code, my_pid) end)

    read() |> Enum.count(fn [type | _] -> type == 2 end)
  end

  defp read(outputs \\ []) do
    receive do
      {:output, output} -> read([output | outputs])
      :eot -> Enum.chunk_every(outputs, 3)
    end
  end

  def part2([_ | code]) do
    my_pid = self()
    pid = spawn(fn -> AdventOfCode.Intcode.run([2 | code], my_pid) end)

    track_ball(%{}, nil, nil, [], pid)
  end

  defp track_ball(map, paddle, ball, [score, 0, -1], pid) do
    case Enum.any?(map, fn {_, type} -> type == 2 end) do
      true -> track_ball(map, paddle, ball, [], pid)
      false -> score
    end
  end

  defp track_ball(map, paddle, ball, [type, y, x], pid) do
    {updated_map, updated_paddle, updated_ball} =
      case type do
        3 -> {map |> Map.put({x, y}, 3) |> print(), {x, y}, ball}
        4 -> {map |> Map.put({x, y}, 4) |> print(), paddle, {x, y}}
        type -> {map |> Map.put({x, y}, type), paddle, ball}
      end

    track_ball(updated_map, updated_paddle, updated_ball, [], pid)
  end

  defp track_ball(map, paddle, ball, buffor, pid) do
    receive do
      {:output, output} ->
        track_ball(map, paddle, ball, [output | buffor], pid)

      :input_required ->
        send(pid, {:input, joystick_move(paddle, ball)})
        track_ball(map, paddle, ball, buffor, pid)

      :eot ->
        "End of transmission"
    end
  end

  defp joystick_move({px, _}, {bx, _}) when px < bx, do: 1
  defp joystick_move({px, _}, {bx, _}) when px > bx, do: -1
  defp joystick_move(_, _), do: 0

  defp to_map(outputs) do
    outputs |> Enum.reduce(%{}, fn [type, y, x], acc -> Map.put(acc, {x, y}, type) end)
  end

  defp print(map) do
    case Enum.count(map) do
      0 ->
        IO.puts("Empty map")

      _ ->
        {{{min_x, _}, _}, {{max_x, _}, _}} = Enum.min_max_by(map, fn {{x, _}, _} -> x end)
        {{{_, min_y}, _}, {{_, max_y}, _}} = Enum.min_max_by(map, fn {{_, y}, _} -> y end)

        for y <- min_y..max_y do
          for x <- min_x..max_x do
            case Map.get(map, {x, y}, 0) do
              0 -> ' '
              1 -> ?|
              2 -> ?#
              3 -> ?-
              4 -> ?*
            end
          end
        end
        |> Enum.intersperse(?\n)
        |> IO.puts()
    end

    map
  end
end
