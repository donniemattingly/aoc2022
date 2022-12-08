defmodule Day6 do
  use Utils.DayBoilerplate, day: 6

  def sample_input do
    """
    bvwbjplbgvbhsrlpgdmjqwftvncz
    """
  end

  def parse_input(input) do
    input |> Utils.split_each_char()
  end

  def solve(input), do: do_solve(input, 4)
  def solve2(input), do: do_solve(input, 14)
  def do_solve(input, num) do
    input
    |> Enum.chunk_every(num, 1)
    |> Enum.take_while(fn x ->
      (MapSet.new(x) |> MapSet.size() < num)
    end)
    |> length()
    |> Kernel.+(num)
  end

  def find_marker(data) do
    # Keep track of the last four characters received
    last_four = ["", "", "", ""]

    # Split the data stream into a list of graphemes
    graphemes = String.graphemes(data)

    # Loop through the graphemes in the data stream
    for i <- 0..length(graphemes) - 1 do
      # Shift the last four characters to make room for the new one
      last_four = [
        Enum.at(last_four, 1),
        Enum.at(last_four, 2),
        Enum.at(last_four, 3),
        Enum.at(graphemes, i)
      ]

      # Check if the last four characters are all different
      if MapSet.size(MapSet.new(last_four)) == 4 do
        # If they are, we have found the marker
        i + 1
      end
    end

    # If we reach this point, no marker was found
    0
  end



end
