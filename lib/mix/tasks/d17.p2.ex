defmodule Mix.Tasks.D17.P2 do
  use Mix.Task

  import AdventOfCode.Day17

  @shortdoc "Day 17 Part 2"
  def run(args) do
    input =
      AdventOfCode.input!("inputs/d17.txt")
      |> List.first()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end

