defmodule Day4 do
  use Utils.DayBoilerplate, day: 4

  def sample_input do
    """
    2-4,6-8
    2-3,4-5
    5-7,7-9
    2-8,3-7
    6-6,4-6
    2-6,4-8
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    String.split(line, ",")
    |> Enum.map(&parse_assignment/1)
  end

  def parse_assignment(assignment) do
    [a, b] =
      assignment
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    MapSet.new(a..b)
  end

  def solve(input) do
    input
    |> Enum.filter(fn [a, b] ->
      MapSet.subset?(a, b) or MapSet.subset?(b, a)
    end)
    |> Enum.count()
  end

  def solve2(input) do
    input
    |> Enum.filter(fn [a, b] ->
      MapSet.disjoint?(a, b)
    end)
    |> Enum.count()
  end
end
