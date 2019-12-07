defmodule AdventOfCode.Day07 do
  @doc """
    ## Examples:
      iex> AdventOfCode.Day07.part1([3, 15, 3, 16, 1002, 16, 10, 16, 1, 16, 15, 15, 4, 15, 99, 0, 0])
      43210
      iex> AdventOfCode.Day07.part1([3, 23, 3, 24, 1002, 24, 10, 24, 1002, 23, -1, 23,
      iex>      101, 5, 23, 23, 1, 24, 23, 23, 4, 23, 99, 0, 0])
      54321
      iex> AdventOfCode.Day07.part1([3, 31, 3, 32, 1002, 32, 10, 32, 1001, 31, -2, 31, 1007, 31, 0, 33,
      iex>      1002, 33, 7, 33, 1, 33, 31, 31, 1, 32, 31, 31, 4, 31, 99, 0, 0, 0])
      65210
  """
  def part1(code) do
    [0, 1, 2, 3, 4]
    |> permutations()
    |> Enum.map(fn permutation -> acs(code, permutation) end)
    |> Enum.max()
  end

  defp acs(code, phases) do
    phases
    |> Enum.reduce(0, fn phase, signal ->
      AdventOfCode.Intcode.run_with_input(code, [phase, signal])
    end)
  end

  defp permutations([]), do: [[]]

  defp permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def part2(code) do
  end
end
