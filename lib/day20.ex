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
    |> Enum.map(fn i -> {i, :unshifted} end)
  end

  def normalize_index(index, length) do
    IO.puts "Normalizing #{index} with length #{length}"
    if index < 0 do
      length + index
    else
      rem(index, length)
    end
  end

  def mix(list, start_index) do
    index = Enum.find_index(list, &(elem(&1, 1) == :unshifted))

    {{num, :unshifted}, removed} = List.pop_at(list, index)

    new_index = normalize_index(index + num, length(list))
    new = List.insert_at(removed, new_index, {num, :shifted})

    IO.puts("shifting num: #{num} at index: #{index} to index: #{new_index}")
    new |> Enum.map(&elem(&1, 0)) |> Enum.join(", ") |> IO.puts()

    IO.puts("")
    if Enum.any?(new, fn {_, state} -> state == :unshifted end) do
      mix(new, 0)
    else
      new
    end
  end

  def solve(input) do
    input
    |> mix(0)
  end
end
