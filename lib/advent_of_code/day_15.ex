defmodule AdventOfCode.Day15 do
  @moves [1, 2, 3, 4]

  def part1(code) do
    {_, cost, _} = find_oxygen(code)

    cost
  end

  defp find_oxygen(code) do
    current_possition = {0, 0}

    %{current_possition => {1, 0, AdventOfCode.Intcode.parse(code)}}
    |> find([current_possition], MapSet.new())
  end

  defp find(board, [possition | targets], visited) do
    {type, cost, state} = Map.get(board, possition)

    case type do
      0 ->
        find(board, targets, MapSet.put(visited, possition))

      1 ->
        updated_board = board |> put_moves(possition)

        find(
          updated_board,
          targets ++ next_possible_moves(updated_board, possition, visited),
          MapSet.put(visited, possition)
        )

      2 ->
        {possition, cost, state}
    end
  end

  defp next_possible_moves(board, current_possition, visited) do
    @moves
    |> Enum.map(fn move -> next_possition(move, current_possition) end)
    |> Enum.reject(fn possition ->
      {result, _, _} = Map.get(board, possition)

      MapSet.member?(visited, possition) or result == 0
    end)
  end

  defp put_moves(current_board, current_possition) do
    {_, cost, current_state} = Map.get(current_board, current_possition)

    @moves
    |> Enum.reduce(current_board, fn move, board ->
      Map.put_new_lazy(board, next_possition(move, current_possition), fn ->
        {:output, new_state, output} = AdventOfCode.Intcode.run(%{current_state | input: move})
        {output, cost + 1, new_state}
      end)
    end)
  end

  defp next_possition(1, {x, y}), do: {x, y - 1}
  defp next_possition(2, {x, y}), do: {x, y + 1}
  defp next_possition(3, {x, y}), do: {x - 1, y}
  defp next_possition(4, {x, y}), do: {x + 1, y}

  def part2(code) do
    {oxygen_possition, _, state} = find_oxygen(code)

    {_, {_, cost, _}} =
      %{oxygen_possition => {2, 0, state}}
      |> build_map([oxygen_possition], MapSet.new())
      |> Enum.max_by(fn {_, {type, cost, _}} -> if type == 1, do: cost, else: 0 end)

    cost
  end

  defp build_map(board, [], _visited), do: board

  defp build_map(board, [possition | targets], visited) do
    {type, _cost, _state} = Map.get(board, possition)

    case type do
      0 ->
        build_map(board, targets, MapSet.put(visited, possition))

      _ ->
        updated_board = board |> put_moves(possition)

        build_map(
          updated_board,
          targets ++ next_possible_moves(updated_board, possition, visited),
          MapSet.put(visited, possition)
        )
    end
  end
end
