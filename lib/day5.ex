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
    lines = a |> String.split("\n", trim: true)
    len = lines |> Enum.map(&String.length/1) |> Enum.max()

    m =
      lines
      |> Enum.map(&String.pad_trailing(&1, len))
      |> Enum.map(&Utils.split_each_char/1)
      |> Utils.list_of_lists_to_map_by_point()

      Enum.zip(1..len/4, 0..length(lines))

#    for b <- 1..len//4 do
#      for a <- 0..length(lines) do
#        Map.get(m, {b, a})
#      end
#      |> Enum.filter(fn
#        nil -> false
#        x -> Regex.match?(~r/\w+/, x)
#      end)
#    end
  end

  def parse_input2(input) do
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

  def solve(input), do: input

  def solve2(input) do
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

  def parse_matrix(matrix) do
    # Split the matrix into lines
    lines = String.split(matrix, "\n")
    # Initialize an empty map to store the parsed matrix
    matrix_map = %{}
    # Loop over the lines in the matrix
    for line <- lines do
      # Initialize the current column number to 1
      col_num = 1
      # Split the line into a list of characters
      chars = String.split(line, "")
      # Loop over the characters in the line
      for ch <- chars do
        # Check if the character is a letter
        if ch in ?a..?z || ch in ?A..?Z do
          # If the character is a letter, add it to the list of letters for the current column
          matrix_map = Map.update(matrix_map, col_num, [ch], &(&1 ++ [ch]))
          # Check if the character is a column number
        else
          if ch in ?0..?9 do
            # If the character is a column number, update the current column number
            col_num = String.to_integer(ch)
          end
        end
      end

      matrix_map
    end
  end
end
