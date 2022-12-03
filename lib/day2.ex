defmodule Day2 do
  use Utils.DayBoilerplate, day: 2

  def sample_input do
    """
    A Y
    B X
    C Z
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(fn x -> String.split(x, " ") |> List.to_tuple() end)
  end

  def score({"A", "X"}), do: 3
  def score({"B", "Y"}), do: 3
  def score({"C", "Z"}), do: 3

  def score({"C", "X"}), do: 6
  def score({"A", "Y"}), do: 6
  def score({"B", "Z"}), do: 6

  def score({"B", "X"}), do: 0
  def score({"C", "Y"}), do: 0
  def score({"A", "Z"}), do: 0

  def score2({"A", "X"}), do: 3
  def score2({"A", "Y"}), do: 4
  def score2({"A", "Z"}), do: 8

  def score2({"B", "X"}), do: 1
  def score2({"B", "Y"}), do: 5
  def score2({"B", "Z"}), do: 9

  def score2({"C", "X"}), do: 2
  def score2({"C", "Y"}), do: 6
  def score2({"C", "Z"}), do: 7

  def val("X"), do: 1
  def val("Y"), do: 2
  def val("Z"), do: 3

  def solve(input) do
    input
    |> Enum.map(fn {a, b} -> score({a, b}) + val(b) end)
    |> Enum.sum()
  end

  def solve2(input) do
    input
    |> Enum.map(&score/1)
    |> Enum.sum()
  end
end
