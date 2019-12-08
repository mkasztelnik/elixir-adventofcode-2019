defmodule AdventOfCode.IntcodeTest do
  use ExUnit.Case
  doctest AdventOfCode.Intcode

  import AdventOfCode.Intcode

  test "3 get command" do
    send(self(), {:input, 5})
    assert run([3, 1, 99], self()) == [3, 5, 99]
  end

  test "4 put command with position mode" do
    run([4, 2, 99], self())

    assert_received {:output, 99}
  end

  test "4 put command with immediate mode" do
    run([104, 2, 99], self())
    assert_received {:output, 2}
  end
end
