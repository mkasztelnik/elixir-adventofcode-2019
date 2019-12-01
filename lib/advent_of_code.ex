defmodule AdventOfCode do
  @moduledoc """
  Documentation for AdventOfCode.
  """

  def input!(path) do
    File.stream!(path)
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.to_list()
  end

  def parse(value) do
    case Integer.parse(value) do
      {i, _} -> i
      :error -> 0
    end
  end
end
