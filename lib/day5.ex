defmodule Day5 do
  use Utils.DayBoilerplate, day: 5

  def sample_input do
    """
        [D]
    [N] [C]
    [Z] [M] [P]
     1   2   3

    move 1 from 2 to 1
    move 3 from 1 to 3
    move 2 from 2 to 1
    move 1 from 1 to 2
    """
  end

  def parse_input(input) do
    [a, b] = String.split(input, "\n\n")

    lines =
      a
      |> String.split("\n")
      |> Enum.map(&parse_line/1)

    height = length(lines)

    max =
      lines
      |> Enum.map(&length/1)
      |> Enum.max()

    m =
      lines
      |> Utils.list_of_lists_to_map_by_point()

    towers =
      0..max
      |> Enum.map(fn x ->
        0..height
        |> Enum.map(fn y ->
          Map.get(m, {x, y})
        end)
        |> Enum.filter(& &1)
      end)
      |> Enum.filter(fn x -> length(x) != 0 end)
      |> Enum.map(fn x ->
        first = Enum.drop(x, -1)
        last = Enum.slice(x, -1, 1) |> hd

        {String.to_integer(last), first}
      end)
      |> Map.new()

    moves =
      b
      |> Utils.split_lines()
      |> Enum.map(fn x ->
        Regex.scan(~r/\d+/, x) |> Enum.map(fn [x] -> String.to_integer(x) end) |> List.to_tuple()
      end)

    {towers, moves}
  end

  def parse_line(line) do
    line
    |> String.graphemes()
    |> Enum.chunk_every(4)
    |> Enum.map(&condense_chunk/1)
  end

  def condense_chunk(chunk) do
    chunk
    |> Enum.filter(fn x -> Regex.match?(~r/[A-Z]|\d/, x) end)
    |> Enum.at(0)
  end

  def solve(input) do
    {t, m} = input

    m
    |> Enum.reduce(t, fn x, acc ->
      do_move(acc, x)
    end)
    |> Map.to_list()
    |> Enum.map(fn {_, [a | _]} -> a end)
    |> Enum.join()
  end

  def solve2(input) do
    {t, m} = input

    m
    |> Enum.reduce(t, fn x, acc ->
      do_move(acc, x, :reverse)
    end)
    |> Map.to_list()
    |> Enum.map(fn {_, [a | _]} -> a end)
    |> Enum.join()
  end

  def do_move(towers, {amt, from, to}, dir \\ :normal) do
    from_list = Map.get(towers, from)

    moving_temp =
      towers
      |> Map.get(from)
      |> Enum.slice(0, amt)

    moving = if dir == :normal, do: Enum.reverse(moving_temp), else: moving_temp

    from_left = Enum.drop(Map.get(towers, from), amt)
    new_to = moving ++ towers[to]

    %{towers | from => from_left, to => new_to}
  end
end
