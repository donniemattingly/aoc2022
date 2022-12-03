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
    l = round(String.length(line) / 2)

    line
    |> String.graphemes()
    |> Enum.split(l) # split in half
    |> Tuple.to_list # {a, b} -> [a, b]
    |> Enum.map(&MapSet.new/1) # convert each to set
    |> Enum.reduce(&MapSet.intersection/2) # get intersection
    |> MapSet.to_list() # back to list
    |> hd # hd gets the head of a list
    |> String.to_charlist() # convert string to charlist (list of integer codepoints)
  end

  def get_group_badge(lines) do
    lines
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.intersection/2)
    |> MapSet.to_list()
    |> hd
    |> String.to_charlist()
  end

  def score(num) when num < ?a, do: num - ?A + 27
  def score(num) when num >= ?a, do: num - ?a + 1

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
