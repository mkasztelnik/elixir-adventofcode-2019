defmodule Mix.Tasks.D12.P1 do
  use Mix.Task

  import AdventOfCode.Day12

  @shortdoc "Day 12 Part 1"
  def run(args) do
    input = AdventOfCode.input!("inputs/d12.txt")

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_1: fn -> input |> part1(1000) end}),
      else:
        input
        |> part1(1000)
        |> IO.inspect(label: "Part 1 Results")
  end
end
