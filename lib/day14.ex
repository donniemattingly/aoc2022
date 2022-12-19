defmodule Day14 do
  use Utils.DayBoilerplate, day: 14

  def sample_input do
    """
    498,4 -> 498,6 -> 496,6
    503,4 -> 502,4 -> 502,9 -> 494,9
    """
  end

  def min_max_of_grid(grid, pos) do
    grid
    |> Map.keys()
    |> Enum.filter(&is_tuple/1)
    |> Enum.map(fn p -> elem(p, pos) end)
    |> Enum.min_max(fn -> {0, 0} end)
  end

  def print_path(grid_map) do
    {min_x, max_x} = min_max_of_grid(grid_map, 0)
    {min_y, max_y} = min_max_of_grid(grid_map, 1)

    p = 0

    Enum.map((min_y - p)..(max_y + p), fn y ->
      Enum.map((min_x - p)..(max_x + p), fn x ->
        case Map.get(grid_map, {x, y}) do
          :rock -> "#"
          :sand -> "o"
          _ -> "."
        end
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.flat_map(&parse_line/1)
  end

  def parse_line(line) do
    line
    |> String.split(" -> ")
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(&{String.to_integer(List.first(&1)), String.to_integer(List.last(&1))})
    |> Enum.chunk_every(2, 1)
    |> Enum.drop(-1)
    |> Enum.map(&List.to_tuple/1)
  end

  def make_initial_grid(input) do
    input
    |> Enum.reduce(
      %{},
      fn {{x1, y1}, {x2, y2}}, acc ->
        for(
          x <- x1..x2,
          y <- y1..y2,
          do: {x, y}
        )
        |> Enum.reduce(acc, fn {x, y}, acc -> Map.put(acc, {x, y}, :rock) end)
      end
    )
  end

  def do_drop_sand(grid, pos = {x, y}) do
    #    IO.puts("")
    #    print_path(grid)
    new_pos =
      [{x, y + 1}, {x - 1, y + 1}, {x + 1, y + 1}]
      |> Enum.find(:stopped, &(Map.get(grid, &1) == nil))

    #      |> IO.inspect()

    {_, max_y} = min_max_of_grid(grid, 1)

    case new_pos do
      :stopped ->
        do_drop_sand(Map.put(grid, pos, :sand), {500, 0})

      {_, y} when y > max_y ->
        Map.put(grid, new_pos, :sand)

      _ ->
        do_drop_sand(grid, new_pos)
    end
  end

  def drop_sand(grid) do
    do_drop_sand(grid, {500, 0})
  end

  def do_drop_sand2(grid, pos = {x, y}) do
    #    Process.sleep(10)

    case :rand.uniform(1000) do
      1 ->
        IO.puts("")
        print_path(grid)

      _ ->
        nil
    end

    {_, max_y} =
      grid
      |> Map.to_list()
      |> Enum.filter(fn {k, v} -> v == :rock end)
      |> Map.new()
      |> min_max_of_grid(1)

    potential =
      [{x, y + 1}, {x - 1, y + 1}, {x + 1, y + 1}]
      |> Enum.find(:stopped, &(Map.get(grid, &1) == nil))

    stop = max_y + 2

    #    IO.inspect(potential, label: "potential")
    #    IO.inspect(stop, label: "stop")

    new_pos =
      case potential do
        :stopped -> :stopped
        {px, py} when py == max_y + 2 -> :stopped
        x -> x
      end

    case {new_pos, pos} do
      {:stopped, {500, 0}} ->
        grid

      {:stopped, _} ->
        do_drop_sand2(Map.put(grid, pos, :sand), {500, 0})

      _ ->
        do_drop_sand2(grid, new_pos)
    end
  end

  def drop_sand2(grid) do
    do_drop_sand2(grid, {500, 0})
  end

  def solve(input) do
    input
    |> make_initial_grid()
    |> drop_sand()
    |> Map.values()
    |> Enum.count(&(&1 == :sand))
  end

  def solve2(input) do
    input
    |> make_initial_grid()
    |> drop_sand2()
    |> Map.values()
    |> Enum.count(&(&1 == :sand))
  end
end
