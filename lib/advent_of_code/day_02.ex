defmodule AdventOfCode.Day02 do
  def part1(codes) do
    codes
    |> List.replace_at(1, 12)
    |> List.replace_at(2, 2)
    |> calculate()
    |> hd()
  end

  @doc """
    Day 1 part 1

    ## Examples:
      iex> AdventOfCode.Day02.calculate([1, 0, 0, 0, 99])
      [2, 0, 0, 0, 99]
      iex> AdventOfCode.Day02.calculate([2, 3, 0, 3, 99])
      [2, 3, 0, 6, 99]
      iex> AdventOfCode.Day02.calculate([2, 4, 4, 5, 99, 0])
      [2, 4, 4, 5, 99, 9801]
      iex> AdventOfCode.Day02.calculate([1, 1, 1, 4, 99, 5, 6, 0, 99])
      [30, 1, 1, 4, 2, 5, 6, 0, 99]
  """
  def calculate(code, index \\ 0) do
    do_calculate(Enum.slice(code, index..-1), index, code)
  end

  defp do_calculate([99 | _], _, code), do: code
  defp do_calculate([operation, first_index, second_index, target_index | _], index, code) do
    value = execute_operation(operation, Enum.at(code, first_index), Enum.at(code, second_index))

    List.replace_at(code, target_index, value) |> calculate(index + 4)
  end

  defp execute_operation(1, first, second), do: first + second
  defp execute_operation(2, first, second), do: first * second

  def part2(_args) do
  end
end
