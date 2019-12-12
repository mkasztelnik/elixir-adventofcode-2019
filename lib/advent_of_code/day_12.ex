defmodule AdventOfCode.Day12 do
  def part1(lines, steps) do
    moons =
      lines
      |> Enum.map(&parse/1)

    [m1, m2, m3, m4] = 1..steps |> Enum.reduce(moons, fn _, moons -> step(moons) end)

    energy(m1) + energy(m2) + energy(m3) + energy(m4)
  end

  defp step([o_m1, o_m2, o_m3, o_m4]) do
    m1 = o_m1 |> update_gravity(o_m2) |> update_gravity(o_m3) |> update_gravity(o_m4)
    m2 = o_m2 |> update_gravity(o_m1) |> update_gravity(o_m3) |> update_gravity(o_m4)
    m3 = o_m3 |> update_gravity(o_m2) |> update_gravity(o_m1) |> update_gravity(o_m4)
    m4 = o_m4 |> update_gravity(o_m2) |> update_gravity(o_m3) |> update_gravity(o_m1)

    [move(m1), move(m2), move(m3), move(m4)]
  end

  defp update_gravity({{px1, py1, pz1}, {vx1, vy1, vz1}}, {{px2, py2, pz2}, _}) do
    {{px1, py1, pz1}, {vx1 + change(px1, px2), vy1 + change(py1, py2), vz1 + change(pz1, pz2)}}
  end

  defp move({{px, py, pz}, {vx, vy, vz}}), do: {{px + vx, py + vy, pz + vz}, {vx, vy, vz}}

  defp change(v1, v2) when v1 > v2, do: -1
  defp change(v1, v2) when v1 < v2, do: 1
  defp change(v1, v2), do: 0

  defp energy({x, y, z}), do: abs(x) + abs(y) + abs(z)
  defp energy({p, v}), do: energy(p) * energy(v)

  def part2(args) do
  end

  defp parse(line) do
    [px, py, pz | _] =
      line
      |> String.split(["<x=", ", y=", ", z=", ">"], trim: true)
      |> Enum.map(fn nr -> nr |> String.trim() end)

    {{String.to_integer(px), String.to_integer(py), String.to_integer(pz)}, {0, 0, 0}}
  end
end
