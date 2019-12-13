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

  defp update_gravity({p1, v1}, {p2, _}), do: {p1, v1 + change(p1, p2)}

  defp move({{px, py, pz}, {vx, vy, vz}}), do: {{px + vx, py + vy, pz + vz}, {vx, vy, vz}}
  defp move({px, vx}), do: {px + vx, vx}

  defp change(v1, v2) when v1 > v2, do: -1
  defp change(v1, v2) when v1 < v2, do: 1
  defp change(_v1, _v2), do: 0

  defp energy({x, y, z}), do: abs(x) + abs(y) + abs(z)
  defp energy({p, v}), do: energy(p) * energy(v)

  def part2(lines) do
    moons =
      lines
      |> Enum.map(&parse/1)

    cycle(x_map(moons))
    |> lcm(cycle(y_map(moons)))
    |> lcm(cycle(z_map(moons)))
  end

  defp x_map([
         {{p1, _, _}, {v1, _, _}},
         {{p2, _, _}, {v2, _, _}},
         {{p3, _, _}, {v3, _, _}},
         {{p4, _, _}, {v4, _, _}}
       ]),
       do: [{p1, v1}, {p2, v2}, {p3, v3}, {p4, v4}]

  defp y_map([
         {{_, p1, _}, {_, v1, _}},
         {{_, p2, _}, {_, v2, _}},
         {{_, p3, _}, {_, v3, _}},
         {{_, p4, _}, {_, v4, _}}
       ]),
       do: [{p1, v1}, {p2, v2}, {p3, v3}, {p4, v4}]

  defp z_map([
         {{_, _, p1}, {_, _, v1}},
         {{_, _, p2}, {_, _, v2}},
         {{_, _, p3}, {_, _, v3}},
         {{_, _, p4}, {_, _, v4}}
       ]),
       do: [{p1, v1}, {p2, v2}, {p3, v3}, {p4, v4}]

  def gcd(a, 0), do: abs(a)
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(a, b), do: div(abs(a * b), gcd(a, b))

  defp cycle(one_dimention_map) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(one_dimention_map, fn x, acc ->
      updated_map = step(acc)

      case updated_map == one_dimention_map do
        true -> {:halt, x}
        false -> {:cont, updated_map}
      end
    end)
  end

  defp parse(line) do
    [px, py, pz | _] =
      line
      |> String.split(["<x=", ", y=", ", z=", ">"], trim: true)
      |> Enum.map(fn nr -> nr |> String.trim() end)

    {{String.to_integer(px), String.to_integer(py), String.to_integer(pz)}, {0, 0, 0}}
  end
end
