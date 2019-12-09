defmodule AdventOfCode.Intcode do
  defstruct code: [], pid: nil, index: 0, relative_base: 0

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
  def run(code, pid) do
    run(%AdventOfCode.Intcode{code: code, pid: pid, index: 0})
  end

  def run(%AdventOfCode.Intcode{code: code, index: index} = state) do
    do_run(Enum.slice(code, index..-1), state)
  end

  defp do_run([operation | tail], state) do
    do_run({rem(operation, 100), div(operation, 100)}, tail, state)
  end

  defp do_run({99, _}, _, %AdventOfCode.Intcode{code: code, pid: pid}) do
    send(pid, :eot)
    code
  end

  defp do_run(
         {3, modes},
         [target_index | _],
         %AdventOfCode.Intcode{code: code, index: index} = state
       ) do
    receive do
      {:input, input} ->
        updated_code = update(code, index(state, target_index, mode(modes, 10)), input)
        run(%{state | code: updated_code, index: index + 2})
    end
  end

  defp do_run(
         {4, mode},
         [source_index | _],
         %AdventOfCode.Intcode{index: index, pid: pid} = state
       ) do
    send(pid, {:output, value(state, source_index, mode)})
    run(%{state | index: index + 2})
  end

  defp do_run(
         {5, modes},
         [source_index, new_index_index | _],
         %AdventOfCode.Intcode{index: index} = state
       ) do
    case value(state, source_index, mode(modes, 10)) != 0 do
      true -> run(%{state | index: value(state, new_index_index, mode(modes, 100))})
      false -> run(%{state | index: index + 3})
    end
  end

  defp do_run(
         {6, modes},
         [source_index, new_index_index | _],
         %AdventOfCode.Intcode{index: index} = state
       ) do
    case value(state, source_index, mode(modes, 10)) == 0 do
      true -> run(%{state | index: value(state, new_index_index, mode(modes, 100))})
      false -> run(%{state | index: index + 3})
    end
  end

  defp do_run(
         {9, modes},
         [source_index | _],
         %AdventOfCode.Intcode{relative_base: relative_base, index: index} = state
       ) do
    diff = value(state, source_index, mode(modes, 10))
    run(%{state | relative_base: relative_base + diff, index: index + 2})
  end

  defp do_run(
         {operation, modes},
         [first_index, second_index, target_index | _],
         %AdventOfCode.Intcode{code: code, index: index} = state
       ) do
    first_value = value(state, first_index, mode(modes, 10))
    second_value = value(state, second_index, mode(modes, 100))
    value = execute_operation(operation, first_value, second_value)
    updated_code = update(code, index(state, target_index, mode(modes, 1000)), value)

    run(%{state | code: updated_code, index: index + 4})
  end

  defp update(code, index, value) do
    code_length = length(code)

    code_to_update =
      case code_length > index do
        true -> code
        false -> code ++ for _i <- 0..(index - code_length), do: 0
      end

    List.replace_at(code_to_update, index, value)
  end

  defp value(%{code: code}, index, 0), do: Enum.at(code, index, 0)
  defp value(%{}, value, 1), do: value
  defp value(%{code: code, relative_base: base}, index, 2), do: Enum.at(code, base + index, 0)

  defp index(%{}, index, 0), do: index
  defp index(%{relative_base: base}, index, 2), do: base + index

  defp mode(modes, mask) do
    modes |> rem(mask) |> div(div(mask, 10))
  end

  defp execute_operation(1, first, second), do: first + second
  defp execute_operation(2, first, second), do: first * second
  defp execute_operation(7, first, second), do: (first < second && 1) || 0
  defp execute_operation(8, first, second), do: (first == second && 1) || 0
end
