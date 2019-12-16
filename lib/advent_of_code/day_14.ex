defmodule AdventOfCode.Day14 do
  import NimbleParsec

  @doc """
    Day 14 part 1

    ## Examples:
      iex> AdventOfCode.Day14.part1(AdventOfCode.input!("inputs/d14-test1.txt"))
      31
      iex> AdventOfCode.Day14.part1(AdventOfCode.input!("inputs/d14-test2.txt"))
      165
      iex> AdventOfCode.Day14.part1(AdventOfCode.input!("inputs/d14-test3.txt"))
      13312
      iex> AdventOfCode.Day14.part1(AdventOfCode.input!("inputs/d14-test4.txt"))
      180697
      iex> AdventOfCode.Day14.part1(AdventOfCode.input!("inputs/d14-test5.txt"))
      2210736
  """
  def part1(reactions_list) do
    {_, ores} =
      reactions_list
      |> Enum.map(&equation/1)
      |> Enum.into(%{})
      |> calculate_cost("FUEL", 1)

    ores
  end

  defp calculate_cost(
         reactions,
         chemical,
         required_amount,
         current_inventory \\ %{},
         current_ores \\ 0
       ) do
    {amount, ingredients} = reactions |> Map.get(chemical)
    quantity = (required_amount / amount) |> Float.ceil() |> Kernel.trunc()

    {inventory, ores} =
      ingredients
      |> Enum.reduce({current_inventory, current_ores}, fn {ingredient, ingredient_amount},
                                                           {inventory, ores} ->
        case ingredient do
          "ORE" ->
            {inventory, ores + quantity * ingredient_amount}

          _ ->
            owned_ingredient_count = Map.get(inventory, ingredient, 0)
            ingredient_count = owned_ingredient_count - quantity * ingredient_amount

            case ingredient_count < 0 do
              false ->
                {Map.put(inventory, ingredient, ingredient_count), ores}

              true ->
                calculate_cost(
                  reactions,
                  ingredient,
                  -ingredient_count,
                  Map.put(inventory, ingredient, 0),
                  ores
                )
            end
        end
      end)

    amount_left = amount * quantity - required_amount
    {Map.update(inventory, chemical, amount_left, fn value -> value + amount_left end), ores}
  end

  defp equation(reaction) do
    {:ok, chemicals, _, _, _, _} = reaction |> chemicals()

    parse_chemicals(chemicals, [])
  end

  defp parse_chemicals([amount, result], acc), do: {result, {amount, acc}}

  defp parse_chemicals([amount, chemical | tail], acc),
    do: parse_chemicals(tail, [{chemical, amount} | acc])

  @doc """
    Day 14 part 1

    ## Examples:
      iex> AdventOfCode.Day14.part2(AdventOfCode.input!("inputs/d14-test3.txt"))
      82892753
      iex> AdventOfCode.Day14.part2(AdventOfCode.input!("inputs/d14-test4.txt"))
      5586022
      iex> AdventOfCode.Day14.part2(AdventOfCode.input!("inputs/d14-test5.txt"))
      460664
  """
  def part2(reactions_list) do
    reactions =
      reactions_list
      |> Enum.map(&equation/1)
      |> Enum.into(%{})

    {inventory, cost} =
      reactions
      |> calculate_cost("FUEL", 1)

    oras = 1_000_000_000_000
    fuel_count = (oras / cost) |> Float.floor() |> Kernel.trunc()

    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while({fuel_count, oras}, fn _, {from, to} ->
      middle = (from + (to - from) / 2) |> Float.floor() |> Kernel.trunc()
      {_, cost} = calculate_cost(reactions, "FUEL", middle)

      case cost < oras do
        true ->
          {_, next_cost} = calculate_cost(reactions, "FUEL", middle + 1)

          if next_cost > oras,
            do: {:halt, middle},
            else: {:cont, {middle, to}}

        false ->
          {:cont, {from, middle}}
      end
    end)
  end

  chemical =
    integer(min: 1, max: 3)
    |> ignore(string(" "))
    |> ascii_string([?A..?Z], min: 1, max: 5)
    |> optional(ignore(string(", ")))

  defparsec(:chemicals, repeat(chemical) |> ignore(string(" => ")) |> concat(chemical))
end
