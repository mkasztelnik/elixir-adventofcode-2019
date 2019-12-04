defmodule AdventOfCode.Day01 do
  @doc """
    Day 1 part 1

    ## Examples:
      iex> AdventOfCode.Day01.part1([12])
      2
      iex> AdventOfCode.Day01.part1([12, 14])
      4
      iex> AdventOfCode.Day01.part1([1969])
      654
      iex> AdventOfCode.Day01.part1([100756])
      33583
  """
  def part1(modules), do: refuel(modules, &fuel/1)

  @doc """
    Day 1 part 2

    ## Examples:
      iex> AdventOfCode.Day01.part2([14])
      2
      iex> AdventOfCode.Day01.part2([1969])
      966
      iex> AdventOfCode.Day01.part2([100756])
      50346
  """
  def part2(modules), do: refuel(modules, &total_fuel/1)

  defp refuel(modules, method) do
    modules |> Enum.reduce(0, fn mass, sum -> sum + method.(mass) end)
  end

  defp total_fuel(mass, total \\ 0)
  defp total_fuel(mass, total) when mass <= 0, do: total - mass

  defp total_fuel(mass, total) do
    fuel = fuel(mass)
    total_fuel(fuel, total + fuel)
  end

  defp fuel(mass) do
    div(mass, 3) - 2
  end
end
