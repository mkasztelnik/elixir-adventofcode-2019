defmodule AdventOfCode.Day05 do
  def part1(code) do
    send(self(), {:input, 1})
    AdventOfCode.Intcode.run(code, self())

    intcode_receive()
  end

  def part2(code) do
    send(self(), {:input, 5})
    AdventOfCode.Intcode.run(code, self())

    intcode_receive()
  end

  defp intcode_receive do
    receive do
      {:output, output} ->
        IO.inspect(output, label: "Output")
        intcode_receive()

      :eot ->
        IO.puts("End of transmission")
    end
  end
end
