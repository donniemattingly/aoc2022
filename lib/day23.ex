defmodule Day23 do
  use Utils.DayBoilerplate, day: 23

  def sample_input do
    """
    .......#......
    .....###.#....
    ...#...#.#....
    ....#...##....
    ...#.###......
    ...##.#.##....
    ....#..#......
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(&Utils.split_each_char/1)
    |> Utils.list_of_lists_to_map_by_point()
    |> Map.to_list()
    |> Enum.filter(fn {_, v} -> v == "#" end)
    |> Map.new()
  end

  @transforms %{
    :N => {0, -1},
    :NE => {1, -1},
    :E => {1, 0},
    :SE => {1, 1},
    :S => {0, 1},
    :SW => {-1, 1},
    :W => {-1, 0},
    :NW => {-1, -1}
  }

  def open_directions(elf = {x, y}, map) do
    neighbors =
      @transforms
      |> Map.to_list()
      |> Enum.map(fn {direction, {dx, dy}} ->
        {direction, Map.get(map, {x + dx, y + dy})}
      end)
      |> Map.new()

    all_empty = fn dir -> Map.get(neighbors, dir) == nil end

    %{
      :N => [:N, :NE, :NW] |> Enum.all?(all_empty),
      :S => [:S, :SE, :SW] |> Enum.all?(all_empty),
      :W => [:W, :NW, :SW] |> Enum.all?(all_empty),
      :E => [:E, :NE, :SE] |> Enum.all?(all_empty)
    }
  end

  @default_order [:N, :S, :W, :E]

  def propose_move(elf = {x, y}, map, ord_num) do
    order = for x <- 0..3, do: Enum.at(@default_order, rem(x + ord_num, 4))
    open_dirs = open_directions(elf, map)

    if Enum.all?(open_dirs, fn {_, v} -> v end) do
      nil
    else
      move_dir = order |> Enum.find(fn dir -> Map.get(open_dirs, dir) end)

      case Map.get(@transforms, move_dir) do
        {dx, dy} -> {x + dx, y + dy}
        _ -> nil
      end
    end
  end

  def run_round(map, order) do
    moves =
      map
      |> Map.to_list()
      |> Enum.map(fn {elf, _} ->
        {elf, propose_move(elf, map, order)}
      end)
      |> Enum.filter(fn {_, v} -> v != nil end)
      |> Enum.group_by(fn {_, v} -> v end)
      |> Map.to_list()
      |> Enum.filter(fn {_, v} -> length(v) == 1 end)
      |> Enum.map(fn {k, [v]} -> v end)
      |> Map.new()


      if moves == %{}, do: raise("No moves on round #{order + 1}")

    map
    |> Map.to_list()
    |> Enum.map(fn {k, v} -> {Map.get(moves, k, k), v} end)
    |> Map.new()
  end

  def solve(input) do
    a =
      input
      |> Map.keys()
      |> hd()

    IO.puts("== Initial State ==")

    res =
      0..9
      |> Enum.reduce(input, fn order, map ->
        IO.puts("\n== End of Round #{order} ==")
        run_round(map, order)
      end)

    {min_x, max_x} = Day14.min_max_of_grid(res, 0)
    {min_y, max_y} = Day14.min_max_of_grid(res, 1)

    Enum.map(min_y..max_y, fn y ->
      Enum.map(min_x..max_x, fn x ->
        case Map.get(res, {x, y}) do
          nil -> 1
          _ -> 0
        end
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def solve2(input) do
    a =
      input
      |> Map.keys()
      |> hd()

    1..1000
    |> Enum.reduce(input, fn order, map ->
      run_round(map, order - 1)
    end)
  end

  def print_elves(grid_map) do
    {min_x, max_x} = Day14.min_max_of_grid(grid_map, 0)
    {min_y, max_y} = Day14.min_max_of_grid(grid_map, 1)

    p = 1

    Enum.map((min_y - p)..(max_y + p), fn y ->
      Enum.map((min_x - p)..(max_x + p), fn x ->
        Map.get(grid_map, {x, y}, ".")
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end
end
