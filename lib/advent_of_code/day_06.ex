defmodule AdventOfCode.Day06 do
  @doc """
    Day 06 part 1

   ## Examples:
    iex> AdventOfCode.Day06.part1(
    iex>   ["COM)B", "B)C", "C)D", "D)E", "E)F", "B)G",
    iex>    "G)H", "D)I", "E)J", "J)K", "K)L"])
    42
  """
  def part1(args) do
    args
    |> build_map()
    |> orbits_count()
  end

  defp build_map(map_entries) do
    map_entries
    |> Enum.reduce(%{}, fn map_entry, acc ->
      [object1, object2] = String.split(map_entry, ")")
      orbits = Map.get(acc, object1, [])

      Map.put(acc, object1, [object2 | orbits])
    end)
  end

  defp orbits_count(map) do
    map
    |> Map.keys()
    |> Enum.reduce(0, fn object, sum ->
      sum + object_orbits_count(map, Map.get(map, object, []), 0)
    end)
  end

  defp object_orbits_count(map, [], sum), do: sum

  defp object_orbits_count(map, [object | tail], sum) do
    object_orbits_count(map, tail ++ Map.get(map, object, []), sum + 1)
  end

  @doc """
    Day 06 part 1

   ## Examples:
    iex> AdventOfCode.Day06.part2(
    iex>   ["COM)B", "B)C", "C)D", "D)E", "E)F", "B)G",
    iex>    "G)H", "D)I", "E)J", "J)K", "K)L", "K)YOU", "I)SAN"])
    4
  """
  def part2(args) do
    args
    |> build_reversed_map()
    |> jumps_count()
  end

  defp build_reversed_map(map_entries) do
    map_entries
    |> Enum.reduce(%{}, fn map_entry, map ->
      [object1, object2] = String.split(map_entry, ")")
      Map.put(map, object2, object1)
    end)
  end

  defp jumps_count(reversed_map) do
    santa_jumps = jumps_for(reversed_map, "SAN")
    my_jumps = jumps_for(reversed_map, "YOU")
    {santa_transfers, my_transfers} = diff(santa_jumps, my_jumps)

    length(santa_transfers) + length(my_transfers)
  end

  defp jumps_for(reversed_map, object, path \\ []) do
    case Map.get(reversed_map, object) do
      nil -> path
      jump -> jumps_for(reversed_map, jump, [jump | path])
    end
  end

  def diff([object | tail1], [object | tail2]), do: diff(tail1, tail2)
  def diff(list1, list2), do: {list1, list2}
end
