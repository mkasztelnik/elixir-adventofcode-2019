defmodule AdventOfCode.Day08 do
  def part1(transmission, width, heigth) do
    {_, layer} =
      transmission
      |> String.graphemes()
      |> Enum.chunk_every(width * heigth)
      |> Enum.map(fn layer -> { count(layer, "0"), layer } end)
      |> Enum.min_by(fn {count, _} -> count end)

    count(layer, "1") * count(layer, "2")
  end

  defp count(layer, code) do
    Enum.count(layer, fn el -> el == code end)
  end

  def part2(transmission, width, heigth) do
    transmission
    |> String.graphemes()
    |> Enum.chunk_every(width * heigth)
    |> Enum.zip()
    |> Enum.map(fn pixel_layers ->
      pixel_layers
      |> Tuple.to_list()
      |> Enum.find(fn pixel -> pixel == "0" or pixel == "1" end)
      |> case do
        "0" -> " "
        "1" -> "*"
      end
    end)
    |> Enum.chunk_every(width)
    |> Enum.map(&Enum.join/1)
    |> Enum.each(&IO.puts/1)
  end
end
