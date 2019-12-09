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

  test "output 16-digit number" do
    run([1102, 34_915_192, 34_915_192, 7, 4, 7, 99, 0], self())

    assert_received {:output, 1_219_070_632_396_864}
  end

  test "output large number" do
    run([104, 1_125_899_906_842_624, 99], self())

    assert_received {:output, 1_125_899_906_842_624}
  end

  test "outputs code" do
    code = [109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99]
    run(code, self())

    assert receive_result([]) == code
  end

  defp receive_result(result) do
    receive do
      {:output, output} -> receive_result([output | result])
      :eot -> Enum.reverse(result)
    end
  end
end
