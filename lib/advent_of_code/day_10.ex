defmodule AdventOfCode.Day10 do
  @doc """
    Day 10 part 1

    ## Examples:
      iex> AdventOfCode.Day10.part1(AdventOfCode.input!("inputs/d10-test1.txt"))
      8
      iex> AdventOfCode.Day10.part1(AdventOfCode.input!("inputs/d10-test2.txt"))
      33
      iex> AdventOfCode.Day10.part1(AdventOfCode.input!("inputs/d10-test3.txt"))
      35
      iex> AdventOfCode.Day10.part1(AdventOfCode.input!("inputs/d10-test4.txt"))
      41
      iex> AdventOfCode.Day10.part1(AdventOfCode.input!("inputs/d10-test5.txt"))
      210
  """
  def part1(lines) do
    points = lines |> parse()

    points
    |> Enum.map(fn point -> observed_count(point, points) end)
    |> Enum.max()
  end

  defp observed_count(point, points, angles \\ MapSet.new)
  defp observed_count(point, [point | tail], angles), do: observed_count(point, tail, angles)
  defp observed_count(_point, [], angles), do: Enum.count(angles)
  defp observed_count(point, [target | tail], angles) do
    observed_count(point, tail, MapSet.put(angles, angle(target, point)))
  end

  defp angle({ax, ay}, {bx, by}) do
    degree = :math.atan2(ax - bx, by - ay) * 180/:math.pi
    if degree < 0, do: 360 + degree, else: degree
  end

  @doc """
    Day 10 part 1

    ## Examples:
      iex> AdventOfCode.Day10.part2(AdventOfCode.input!("inputs/d10-test5.txt"))
      802
  """
  def part2(lines) do
    points = lines |> parse()

    base = Enum.max_by(points, fn point -> observed_count(point, points) end)

    {{x, y}, _, _} =
      points
      |> Enum.reject(fn point -> point == base end)
      |> Enum.map(fn point -> {point, angle(point, base), distance(point, base)} end)
      |> Enum.sort_by(fn {_, angle, distance} -> {angle, distance} end)
      |> Enum.chunk_by(fn {_, angle, _} -> angle end)
      |> sort_targets()
      |> Enum.at(199)

    100 * x + y
  end

  defp sort_targets(ordered_maps, buffer \\ [], ordered \\ [])
  defp sort_targets([], [], ordered) do
    Enum.reverse(ordered)
  end

  defp sort_targets([[h] | tail], buffer, ordered) do
    sort_targets(tail, buffer, [h | ordered])
  end

  defp sort_targets([[h | t] | tail], buffer, ordered) do
    sort_targets(tail, [t | buffer], [h | ordered])
  end

  defp sort_targets([], buffer, ordered) do
    sort_targets(Enum.reverse(buffer), [], ordered)
  end
  #
  # defp targets(base, map, targets \\ [])
  # defp targets(base, [base | map], targets), do: targets(base, map, targets)
  # defp targets(_base, [], targets), do: targets
  # defp targets(base, [target | map], targets) do
  #   updated_targets = [{target, angle(base, target), length(base, target)} | targets]
  #   targets(base, map, updated_targets)
  # end

  defp distance({ax, ay}, {bx, by}) do
    :math.pow(ax - bx, 2) + :math.pow(ay - by, 2) |> :math.sqrt()
  end

  defp parse(lines) do
    {_, lines} =
      lines
      |> Enum.reduce({0, []}, fn line, {y, map} ->
        {y + 1, parse_line(String.to_charlist(line), map, 0, y)}
      end)

    lines
  end

  defp parse_line([?. | tail], map, x, y), do: parse_line(tail, map, x + 1, y)
  defp parse_line([?# | tail], map, x, y), do: parse_line(tail, [{x, y} | map], x + 1, y)
  defp parse_line([], map, _, _), do: map
end
