defmodule Mix.Tasks.D16.P2 do
  use Mix.Task

  import AdventOfCode.Day16

  @shortdoc "Day 16 Part 2"
  def run(args) do
    input = AdventOfCode.input!("inputs/d16.txt") |> hd()

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
