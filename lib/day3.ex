defmodule Day3 do
  use Utils.DayBoilerplate, day: 3

  def sample_input do
    """
    vJrwpWtwJgWrhcsFMMfFFhFp
    jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
    PmmdzqPrVvPwwTWBwg
    wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
    ttgJtRGJQctTZtZT
    CrZsJsPPZsGzwwsLwLmpwMDw
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
  end

  def get_common_char(line) do
    l = String.length(line)
    a = String.slice(line, 0, floor(l / 2))
    b = String.slice(line, floor(l / 2), l)

    a_set = a |> String.graphemes() |> MapSet.new()
    b_set = b |> String.graphemes() |> MapSet.new()

    MapSet.intersection(a_set, b_set) |> MapSet.to_list() |> hd |> String.to_charlist()
  end

  def get_group_badge(lines) do
    [a, b, c] = lines
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&MapSet.new/1)

    MapSet.intersection(a, b)
    |> MapSet.intersection(c)
    |> MapSet.to_list() |> hd |> String.to_charlist()
  end

  def score(num) when num < 97, do: num - 65 + 27
  def score(num) when num >= 97, do: num - 97 + 1

  def solve(input) do
    input
    |> Enum.map(&get_common_char/1)
    |> Enum.map(&hd/1)
    |> Enum.map(&score/1)
    |> Enum.sum
  end

  def solve2(input) do
    input
    |> Enum.chunk_every(3)
    |> Enum.map(&get_group_badge/1)
    |> Enum.map(&hd/1)
    |> Enum.map(&score/1)
    |> Enum.sum
  end
end
