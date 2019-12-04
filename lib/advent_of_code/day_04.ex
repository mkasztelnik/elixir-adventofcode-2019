defmodule AdventOfCode.Day04 do
  def part1(range) do
    range |> Enum.count(fn d -> Integer.digits(d) |> password?() end)
  end

  @doc """
    Day 4 part 1 password check

    ## Examples:
      iex> AdventOfCode.Day04.password?(Integer.digits(11223))
      false
      iex> AdventOfCode.Day04.password?(Integer.digits(1122334))
      false
      iex> AdventOfCode.Day04.password?(Integer.digits(112233))
      true
      iex> AdventOfCode.Day04.password?(Integer.digits(223450))
      false
      iex> AdventOfCode.Day04.password?(Integer.digits(123789))
      false
  """
  def password?([d1, d2, d3, d4, d5, d6] = digits)
      when d1 <= d2 and d2 <= d3 and d3 <= d4 and d4 <= d5 and d5 <= d6 do
    doubled?(digits)
  end

  def password?(_), do: false

  defp doubled?([d, d, _, _, _, _]), do: true
  defp doubled?([_, d, d, _, _, _]), do: true
  defp doubled?([_, _, d, d, _, _]), do: true
  defp doubled?([_, _, _, d, d, _]), do: true
  defp doubled?([_, _, _, _, d, d]), do: true
  defp doubled?(_), do: false

  def part2(range) do
    range |> Enum.count(fn d -> Integer.digits(d) |> improved_password?() end)
  end

  @doc """
    Day 4 part 2 password check

    ## Examples:
      iex> AdventOfCode.Day04.improved_password?(Integer.digits(11223))
      false
      iex> AdventOfCode.Day04.improved_password?(Integer.digits(1122334))
      false
      iex> AdventOfCode.Day04.improved_password?(Integer.digits(112233))
      true
      iex> AdventOfCode.Day04.improved_password?(Integer.digits(223450))
      false
      iex> AdventOfCode.Day04.improved_password?(Integer.digits(123789))
      false
      iex> AdventOfCode.Day04.improved_password?(Integer.digits(123444))
      false
      iex> AdventOfCode.Day04.improved_password?(Integer.digits(111122))
      true
  """
  def improved_password?([d1, d2, d3, d4, d5, d6] = digits)
      when d1 <= d2 and d2 <= d3 and d3 <= d4 and d4 <= d5 and d5 <= d6 do
    digits |> Enum.group_by(& &1) |> Enum.any?(fn {_, group} -> length(group) == 2 end)
  end

  def improved_password?(_), do: false
end
