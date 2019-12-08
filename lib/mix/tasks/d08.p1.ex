defmodule Mix.Tasks.D08.P1 do
  use Mix.Task

  import AdventOfCode.Day08

  @shortdoc "Day 08 Part 1"
  def run(args) do
    input = AdventOfCode.input!("inputs/d08.txt") |> hd()

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_1: fn -> input |> part1(25, 6) end}),
      else:
        input
        |> part1(25, 6)
        |> IO.inspect(label: "Part 1 Results")
  end
end
