defmodule AdventOfCode.Intcode do
  @doc """
    ## Examples:
      iex> AdventOfCode.Intcode.run([1, 0, 0, 0, 99])
      [2, 0, 0, 0, 99]
      iex> AdventOfCode.Intcode.run([2, 3, 0, 3, 99])
      [2, 3, 0, 6, 99]
      iex> AdventOfCode.Intcode.run([2, 4, 4, 5, 99, 0])
      [2, 4, 4, 5, 99, 9801]
      iex> AdventOfCode.Intcode.run([1, 1, 1, 4, 99, 5, 6, 0, 99])
      [30, 1, 1, 4, 2, 5, 6, 0, 99]
      iex> AdventOfCode.Intcode.run([1002, 4, 3, 4, 33])
      [1002, 4, 3, 4, 99]
  """
  def run(code, index \\ 0) do
    do_run(Enum.slice(code, index..-1), index, code)
  end

  defp do_run([operation | tail], index, code) do
    do_run({rem(operation, 100), div(operation, 100)}, tail, index, code)
  end

  defp do_run({99, _}, _, _, code), do: code

  defp do_run({3, 0}, [target_index | _], index, code) do
    input = IO.gets("Input:") |> String.trim() |> String.to_integer()

    List.replace_at(code, target_index, input) |> run(index + 2)
  end

  defp do_run({4, mode}, [source_index | _], index, code) do
    value(code, source_index, mode) |> IO.puts()
    run(code, index + 2)
  end

  defp do_run({operation, modes}, [first_index, second_index, target_index | _], index, code) do
    first_value = value(code, first_index, mode(modes, 10))
    second_value = value(code, second_index, mode(modes, 100))
    value = execute_operation(operation, first_value, second_value)

    List.replace_at(code, target_index, value) |> run(index + 4)
  end

  defp value(code, index, 0), do: Enum.at(code, index)
  defp value(_, value, 1), do: value

  defp mode(modes, mask) do
    modes |> rem(mask) |> div(div(mask, 10))
  end

  defp execute_operation(1, first, second), do: first + second
  defp execute_operation(2, first, second), do: first * second
end
