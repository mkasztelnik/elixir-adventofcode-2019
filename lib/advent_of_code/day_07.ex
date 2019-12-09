defmodule AdventOfCode.Day07 do
  # @doc """
  #   ## Examples:
  #     iex> AdventOfCode.Day07.part1([3, 15, 3, 16, 1002, 16, 10, 16, 1, 16, 15, 15, 4, 15, 99, 0, 0])
  #     43210
  #     iex> AdventOfCode.Day07.part1([3, 23, 3, 24, 1002, 24, 10, 24, 1002, 23, -1, 23,
  #     iex>      101, 5, 23, 23, 1, 24, 23, 23, 4, 23, 99, 0, 0])
  #     54321
  #     iex> AdventOfCode.Day07.part1([3, 31, 3, 32, 1002, 32, 10, 32, 1001, 31, -2, 31, 1007, 31, 0, 33,
  #     iex>      1002, 33, 7, 33, 1, 33, 31, 31, 1, 32, 31, 31, 4, 31, 99, 0, 0, 0])
  #     65210
  # """
  def part1(code) do
    [0, 1, 2, 3, 4]
    |> permutations()
    |> Enum.map(fn permutation -> acs(code, permutation) end)
    |> Enum.max()
  end

  defp acs(code, phases) do
    phases
    |> Enum.reduce(0, fn phase, signal ->
      send(self(), {:input, phase})
      send(self(), {:input, signal})

      AdventOfCode.Intcode.run(code, self())

      receive do
        {:output, output} -> output
      end
    end)
  end

  defp permutations([]), do: [[]]

  defp permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  @doc """
    ## Examples:
      iex> AdventOfCode.Day07.part2(
      iex>   [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,
      iex>    27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5])
      139629729
      iex> AdventOfCode.Day07.part2(
      iex>   [3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,
      iex>    -5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,
      iex>    53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10])
      18216
  """
  def part2(code) do
    [5, 6, 7, 8, 9]
    |> permutations()
    |> pmap(fn permutation -> feedback_loop(code, permutation) end)
    |> Enum.max()
  end

  def pmap(collection, func) do
    collection
    |> Enum.map(&Task.async(fn -> func.(&1) end))
    |> Enum.map(&Task.await/1)
  end

  def feedback_loop(code, [p1, p2, p3, p4, p5]) do
    amp_e = run_with_output_to(code, self())
    amp_d = run_with_output_to(code)
    amp_c = run_with_output_to(code)
    amp_b = run_with_output_to(code)
    amp_a = run_with_output_to(code)

    send(amp_a, {:receiver, amp_b})
    send(amp_b, {:receiver, amp_c})
    send(amp_c, {:receiver, amp_d})
    send(amp_d, {:receiver, amp_e})
    send(amp_e, {:receiver, amp_a})

    send(amp_a, {:input, p1})
    send(amp_b, {:input, p2})
    send(amp_c, {:input, p3})
    send(amp_d, {:input, p4})
    send(amp_e, {:input, p5})

    send(amp_a, {:input, 0})

    receive do
      {:result, result} -> result
    end
  end

  defp run_with_output_to(code, last_result_receiver \\ nil) do
    spawn(fn ->
      my_pid = self()
      worker = spawn(fn -> AdventOfCode.Intcode.run(code, my_pid) end)

      receive do
        {:receiver, pid} -> forward_to(worker, pid, last_result_receiver)
      end
    end)
  end

  defp forward_to(worker, pid, last_input_receiver, result \\ nil) do
    receive do
      {:input, input} ->
        send(worker, {:input, input})
        forward_to(worker, pid, last_input_receiver, result)

      {:output, output} ->
        send(pid, {:input, output})
        forward_to(worker, pid, last_input_receiver, output)

      :eot ->
        last_input_receiver && send(last_input_receiver, {:result, result})
    end
  end
end
