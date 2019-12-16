defmodule AdventOfCode.Intcode do
  defstruct code: [], index: 0, relative_base: 0, input: nil

  def parse(code) do
    {_, map} =
      code
      |> Enum.reduce({0, %{}}, fn instruction, {index, map} ->
        {index + 1, Map.put(map, index, instruction)}
      end)

    %AdventOfCode.Intcode{code: map, index: 0}
  end

  @doc """
    ## Examples:
      iex> AdventOfCode.Intcode.run([1, 0, 0, 0, 99], self())
      %{0 => 2, 1 => 0, 2 => 0, 3 => 0, 4 => 99}
      iex> AdventOfCode.Intcode.run([2, 3, 0, 3, 99], self())
      %{0 => 2, 1 => 3, 2 => 0, 3 => 6, 4 => 99}
      iex> AdventOfCode.Intcode.run([2, 4, 4, 5, 99, 0], self())
      %{0 => 2, 1 => 4, 2 => 4, 3 => 5, 4 => 99, 5 => 9801}
      iex> AdventOfCode.Intcode.run([1, 1, 1, 4, 99, 5, 6, 0, 99], self())
      %{0 => 30, 1 => 1, 2 => 1, 3 => 4, 4 => 2, 5 => 5, 6 => 6, 7 => 0, 8 => 99}
      iex> AdventOfCode.Intcode.run([1002, 4, 3, 4, 33], self())
      %{0 => 1002, 1 => 4, 2 => 3, 3 => 4, 4 => 99}
  """
  def run(code, pid) when is_list(code) do
    code |> parse() |> run(pid)
  end

  def run(%AdventOfCode.Intcode{} = initial_state, pid) when is_pid(pid) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(initial_state, fn _, state ->
      case run(state) do
        {:eot, %AdventOfCode.Intcode{code: code}} ->
          send(pid, :eot)
          {:halt, code}

        {:input_required, new_state} ->
          send(pid, :input_required)

          receive do
            {:input, input} -> {:cont, %{new_state | input: input}}
          end

        {:output, new_state, output} ->
          send(pid, {:output, output})
          {:cont, new_state}
      end
    end)
  end

  def run(%AdventOfCode.Intcode{code: code, index: index} = state) do
    operation = Map.get(code, index)
    do_run({rem(operation, 100), div(operation, 100)}, state)
  end

  defp do_run({99, _}, %AdventOfCode.Intcode{} = state) do
    {:eot, state}
  end

  defp do_run(
         {3, modes},
         %AdventOfCode.Intcode{code: code, index: index, input: input} = state
       ) do
    case input do
      nil ->
        {:input_required, state}

      val ->
        updated_code = update(code, index(state, Map.get(code, index + 1), mode(modes, 10)), val)
        run(%{state | code: updated_code, index: index + 2, input: nil})
    end
  end

  defp do_run(
         {4, mode},
         %AdventOfCode.Intcode{code: code, index: index} = state
       ) do
    {:output, %{state | index: index + 2}, value(state, Map.get(code, index + 1), mode)}
  end

  defp do_run(
         {5, modes},
         %AdventOfCode.Intcode{code: code, index: index} = state
       ) do
    case value(state, Map.get(code, index + 1), mode(modes, 10)) != 0 do
      true -> run(%{state | index: value(state, Map.get(code, index + 2), mode(modes, 100))})
      false -> run(%{state | index: index + 3})
    end
  end

  defp do_run(
         {6, modes},
         %AdventOfCode.Intcode{code: code, index: index} = state
       ) do
    case value(state, Map.get(code, index + 1), mode(modes, 10)) == 0 do
      true -> run(%{state | index: value(state, Map.get(code, index + 2), mode(modes, 100))})
      false -> run(%{state | index: index + 3})
    end
  end

  defp do_run(
         {9, modes},
         %AdventOfCode.Intcode{code: code, relative_base: relative_base, index: index} = state
       ) do
    diff = value(state, Map.get(code, index + 1), mode(modes, 10))
    run(%{state | relative_base: relative_base + diff, index: index + 2})
  end

  defp do_run(
         {operation, modes},
         %AdventOfCode.Intcode{code: code, index: index} = state
       ) do
    first_value = value(state, Map.get(code, index + 1), mode(modes, 10))
    second_value = value(state, Map.get(code, index + 2), mode(modes, 100))
    value = execute_operation(operation, first_value, second_value)
    updated_code = update(code, index(state, Map.get(code, index + 3), mode(modes, 1000)), value)

    run(%{state | code: updated_code, index: index + 4})
  end

  defp update(code, index, value) do
    Map.put(code, index, value)
  end

  defp value(%{code: code}, index, 0), do: Map.get(code, index, 0)
  defp value(%{}, value, 1), do: value
  defp value(%{code: code, relative_base: base}, index, 2), do: Map.get(code, base + index, 0)

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
