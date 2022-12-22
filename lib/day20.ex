defmodule Day20 do
  use Utils.DayBoilerplate, day: 20

  def sample_input do
    """
    1
    2
    -3
    3
    -2
    0
    4
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
  end

  def mix({x, i}, list) do
    move_index = Enum.find_index(list, &(&1 == {x, i}))
    {h, t} = Enum.split(list, move_index)
    new_l = h ++ Enum.drop(t, 1)
    length = length(new_l)
    new_index = rem(length + rem(move_index + x, length), length)

    #    IO.puts(
    #      "#{} moves between #{Enum.at(list, new_index) |> elem(0)} and #{Enum.at(list, new_index + 1) |> elem(0)}: "
    #    )

    new = List.insert_at(new_l, new_index, {x, i})
    #    new |> Enum.map(&elem(&1, 0)) |> Enum.join(", ") |> IO.puts()
    new
  end

  def solve(input) do
    mixed = input |> Enum.reduce(input, &mix/2)
    base = Enum.find_index(mixed, fn {val, _} -> val == 0 end)

    [1000, 2000, 3000]
    |> Enum.map(fn i -> Enum.at(mixed, rem(base + i, length(mixed))) |> elem(0) end)
    |> Enum.sum()
  end

  def solve2(input) do
    orig = input |> Enum.map(fn {x, i} -> {x * 811_589_153, i} end)
    mixed = (for _ <- 1..10, do: orig)
    |> Enum.reduce(fn x, acc -> x ++ acc end)
    |> Enum.reduce(orig, &mix/2)

    base = Enum.find_index(mixed, fn {val, _} -> val == 0 end)
    [1000, 2000, 3000]
    |> Enum.map(fn i -> Enum.at(mixed, rem(base + i, length(mixed))) |> elem(0) end)
    |> Enum.sum()
  end
end
