defmodule AdventOfCode.Day16 do
  @doc """
    Day 16 part 1

    ## Examples:
      iex> AdventOfCode.Day16.part1("80871224585914546619083218645595")
      "24176176"
      iex> AdventOfCode.Day16.part1("19617804207202209144916044189917")
      "73745418"
      iex> AdventOfCode.Day16.part1("69317163492948606335995924319873")
      "52432133"
  """
  def part1(line) do
    list = line |> parse()

    1..100
    |> Enum.reduce(list, fn _, l -> fft(l) end)
    |> Enum.take(8)
    |> Enum.join("")
  end

  defp parse(line) do
    line |> String.codepoints() |> Enum.map(&String.to_integer/1)
  end

  defp fft(list) do
    {_, result} =
      list
      |> Enum.reduce({0, []}, fn _, {index, values} ->
        {index + 1, [item_fft(list, index) | values]}
      end)

    Enum.reverse(result)
  end

  defp item_fft(list, index) do
    {_, multiplied} =
      list
      |> Enum.reduce({0, []}, fn v, {current, values} ->
        {current + 1, [multiplier(current, index) * v | values]}
      end)

    multiplied
    |> Enum.sum()
    |> rem(10)
    |> abs()
  end

  defp multiplier(current, index) do
    div(current + 1, index + 1) |> rem(4) |> value()
  end

  defp value(0), do: 0
  defp value(1), do: 1
  defp value(2), do: 0
  defp value(3), do: -1

  @doc """
    Day 16 part 2

    ## Examples:
      iex> AdventOfCode.Day16.part2("03036732577212944063491565474664")
      "84462026"
      iex> AdventOfCode.Day16.part2("02935109699940807407585447034323")
      "78725270"
      iex> AdventOfCode.Day16.part2("03081770884921959731165446850517")
      "53553731"
  """
  def part2(line) do
    offset = line |> String.slice(0, 7) |> String.to_integer()

    list =
      line
      |> String.duplicate(10000)
      |> String.slice(offset..-1)
      |> parse()
      |> Enum.reverse()

    1..100
    |> Enum.reduce(list, fn _, l -> fft2(l) end)
    |> Enum.reverse()
    |> Enum.take(8)
    |> Enum.join("")
  end

  defp fft2(list) do
    {_, updated_list} =
      list
      |> Enum.reduce({0, []}, fn v, {last, result} ->
        current = last + v
        {current, [current |> rem(10) | result]}
      end)

    Enum.reverse(updated_list)
  end
end
