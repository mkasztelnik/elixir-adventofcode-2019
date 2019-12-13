defmodule AdventOfCode.Day13 do
  def part1(code) do
    my_pid = self()
    pid = spawn(fn -> AdventOfCode.Intcode.run(code, my_pid) end)

    read()
    |> Enum.count(fn [type | _] -> type == 2 end)
  end

  defp read(outputs \\ []) do
    receive do
      {:output, output} -> read([output | outputs])
      :eot -> Enum.chunk_every(outputs, 3)
    end
  end

  def part2(args) do
  end
end
