defmodule Day1 do
  use Utils.DayBoilerplate, day: 1

  def sample_input do
    """
    1000
    2000
    3000

    4000

    5000
    6000

    7000
    8000
    9000

    10000
    """
  end

  def parse_input(input) do
    input

  end

  def solve(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(fn x -> x |> Utils.split_lines() |> Enum.map(&String.to_integer/1) |> Enum.sum end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.take(3)
    |> Enum.sum()
  end
end
