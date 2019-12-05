defmodule AdventOfCode.Day03Test do
  use ExUnit.Case
  doctest AdventOfCode.Intcode

  import AdventOfCode.Intcode
  import ExUnit.CaptureIO

  test "3 get command" do
    capture_io([input: "5", capture_prompt: false], fn ->
      result = run([3, 1, 99])
      send(self(), result)
    end)

    assert_received [3, 5, 99]
  end

  test "4 get command with position mode" do
    assert capture_io(fn -> run([4, 2, 99]) end) == "99\n"
  end

  test "4 get command with immediate mode" do
    assert capture_io(fn -> run([104, 2, 99]) end) == "2\n"
  end
end
