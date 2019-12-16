defmodule AdventOfCode.Day02 do
  def part1(code) do
    AdventOfCode.Intcode.parse(code)
    |> calculate(12, 2)
  end

  def calculate(%AdventOfCode.Intcode{code: code} = state, noun, verb) do
    %{state | code: code |> Map.put(1, noun) |> Map.put(2, verb)}
    |> AdventOfCode.Intcode.run(self())
    |> Map.get(0)
  end

  def part2(code) do
    code_map = AdventOfCode.Intcode.parse(code)
    scope = for x <- 0..99, y <- 0..99, do: [x, y]
    [noun, verb] = Enum.find(scope, fn [n, v] -> calculate(code_map, n, v) == 19_690_720 end)

    100 * noun + verb
  end
end
