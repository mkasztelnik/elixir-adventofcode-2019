defmodule AdventOfCode do
  @moduledoc """
  Documentation for AdventOfCode.
  """

  def input!(path) do
    File.stream!(path)
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.to_list()
  end
end
