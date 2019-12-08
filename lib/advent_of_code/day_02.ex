defmodule AdventOfCode.Day02 do
  def part1(code) do
    calculate(code, 12, 2)
  end

  def calculate(code, noun, verb) do
    code
    |> List.replace_at(1, noun)
    |> List.replace_at(2, verb)
    |> AdventOfCode.Intcode.run(self())
    |> hd()
  end

  def part2(code) do
    scope = for x <- 0..99, y <- 0..99, do: [x, y]
    [noun, verb] = Enum.find(scope, fn [n, v] -> calculate(code, n, v) == 19_690_720 end)

    100 * noun + verb
  end
end
