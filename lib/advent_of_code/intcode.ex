defmodule AdventOfCode.Intcode do
  @doc """
    ## Examples:
      iex> AdventOfCode.Intcode.run([1, 0, 0, 0, 99], self())
      [2, 0, 0, 0, 99]
      iex> AdventOfCode.Intcode.run([2, 3, 0, 3, 99], self())
      [2, 3, 0, 6, 99]
      iex> AdventOfCode.Intcode.run([2, 4, 4, 5, 99, 0], self())
      [2, 4, 4, 5, 99, 9801]
      iex> AdventOfCode.Intcode.run([1, 1, 1, 4, 99, 5, 6, 0, 99], self())
      [30, 1, 1, 4, 2, 5, 6, 0, 99]
      iex> AdventOfCode.Intcode.run([1002, 4, 3, 4, 33], self())
      [1002, 4, 3, 4, 99]
  """
  def run(code, pid, index \\ 0) do
    do_run(Enum.slice(code, index..-1), index, code, pid)
  end

  defp do_run([operation | tail], index, code, pid) do
    do_run({rem(operation, 100), div(operation, 100)}, tail, index, code, pid)
  end

  defp do_run({99, _}, _, _, code, pid) do
    send(pid, :eot)
    code
  end

  defp do_run({3, 0}, [target_index | _], index, code, pid) do
    receive do
      {:input, input} ->
        List.replace_at(code, target_index, input) |> run(pid, index + 2)
    end
  end

  defp do_run({4, mode}, [source_index | _], index, code, pid) do
    send(pid, {:output, value(code, source_index, mode)})
    run(code, pid, index + 2)
  end

  defp do_run({5, modes}, [source_index, new_index_index | _], index, code, pid) do
    case value(code, source_index, mode(modes, 10)) != 0 do
      true -> run(code, pid, value(code, new_index_index, mode(modes, 100)))
      false -> run(code, pid, index + 3)
    end
  end

  defp do_run({6, modes}, [source_index, new_index_index | _], index, code, pid) do
    case value(code, source_index, mode(modes, 10)) == 0 do
      true -> run(code, pid, value(code, new_index_index, mode(modes, 100)))
      false -> run(code, pid, index + 3)
    end
  end

  defp do_run({operation, modes}, [first_index, second_index, target_index | _], index, code, pid) do
    first_value = value(code, first_index, mode(modes, 10))
    second_value = value(code, second_index, mode(modes, 100))
    value = execute_operation(operation, first_value, second_value)

    List.replace_at(code, target_index, value) |> run(pid, index + 4)
  end

  defp value(code, index, 0), do: Enum.at(code, index)
  defp value(_, value, 1), do: value

  defp mode(modes, mask) do
    modes |> rem(mask) |> div(div(mask, 10))
  end

  defp execute_operation(1, first, second), do: first + second
  defp execute_operation(2, first, second), do: first * second
  defp execute_operation(7, first, second), do: (first < second && 1) || 0
  defp execute_operation(8, first, second), do: (first == second && 1) || 0
end
