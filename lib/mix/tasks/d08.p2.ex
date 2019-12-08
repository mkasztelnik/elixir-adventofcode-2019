defmodule Mix.Tasks.D08.P2 do
  use Mix.Task

  import AdventOfCode.Day08

  @shortdoc "Day 08 Part 2"
  def run(args) do
    input = AdventOfCode.input!("inputs/d08.txt") |> hd()

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2(25, 6) end}),
      else:
        input
        |> part2(25, 6)
        |> IO.inspect(label: "Part 2 Results")
  end
end
