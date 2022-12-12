defmodule Day12 do
  use Utils.DayBoilerplate, day: 12

  def sample_input do
    """
    Sabqponm
    abcryxxl
    accszExk
    acctuvwj
    abdefghi
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(fn line ->
      line
      |> Utils.split_each_char()
      |> Enum.map(&parse_char/1)
    end)
    |> Utils.list_of_lists_to_map_by_point()
    |> Enum.flat_map(fn {point, char} ->
      case char do
        :start -> [{point, ?s - ?a}, {:start, point}]
        :end -> [{point, ?z - ?a}, {:end, point}]
        _ -> [{point, char}]
      end
    end)
    |> Map.new()
  end

  def parse_char("S"), do: :start
  def parse_char("E"), do: :end
  def parse_char(char), do: :binary.first(char) - ?a

  def neighbor_for_point(map, :end), do: []
  def neighbor_for_point(map, :start), do: []

  def neighbor_for_point(map, {x, y}) do
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    |> Enum.map(fn
      {dx, dy} -> {x + dx, y + dy}
    end)
  end

  def find_pos(grid_map, char_code) do
    grid_map
    |> Enum.find(fn {_, v} -> v == char_code - ?a end)
    |> elem(0)
  end

  def solve(grid_map) do
    g = Graph.new()

    edges =
      Map.keys(grid_map)
      |> Enum.flat_map(fn point ->
        neighbor_for_point(grid_map, point)
        |> Enum.filter(fn neighbor ->
          grid_map[neighbor] <= grid_map[point] + 1
        end)
        |> Enum.map(fn neighbor ->
          {point, neighbor}
        end)
      end)

    g = Graph.add_edges(g, edges)

    path = Graph.get_shortest_path(g, grid_map[:start], grid_map[:end])

    Enum.map(path, fn point ->
      grid_map[point]
    end)
    |> IO.inspect(label: "path values")

    print_path(grid_map, path)
    length(path)
  end

  def solve2(grid_map) do
    g = Graph.new()

    edges =
      Map.keys(grid_map)
      |> Enum.flat_map(fn point ->
        neighbor_for_point(grid_map, point)
        |> Enum.filter(fn neighbor ->
          grid_map[neighbor] <= grid_map[point] + 1
        end)
        |> Enum.map(fn neighbor ->
          {point, neighbor}
        end)
      end)

    g = Graph.add_edges(g, edges)

    Map.keys(grid_map)
    |> Enum.filter(fn point ->
      grid_map[point] == 0
    end)
    |> Enum.map(fn point ->
      path = Graph.get_shortest_path(g, point, grid_map[:end])
    end)
    |> Enum.filter(& &1)
    |> Enum.map(&length/1)
    |> Enum.min()
  end

  def get_dir_change(nil, _), do: "x"

  def get_dir_change({x1, y1}, {x2, y2}) do
    case {x1 - x2, y1 - y2} do
      {0, 1} -> "^"
      {0, -1} -> "v"
      {1, 0} -> "<"
      {-1, 0} -> ">"
    end
  end

  def print_path(grid_map, path) do
    max_x =
      grid_map
      |> Map.keys()
      |> Enum.filter(&is_tuple/1)
      |> Enum.map(fn {x, _} -> x end)
      |> Enum.max()

    max_y =
      grid_map
      |> Map.keys()
      |> Enum.filter(&is_tuple/1)
      |> Enum.map(fn {_, y} -> y end)
      |> Enum.max()

    path_index =
      path
      |> Enum.with_index()
      |> Map.new()

    Enum.map(0..max_y, fn y ->
      Enum.map(0..max_x, fn x ->
        s = grid_map[:start]
        e = grid_map[:end]

        case {x, y} do
          ^s ->
            "S"

          ^e ->
            "E"

          _ ->
            case path_index[{x, y}] do
              nil ->
                "."

              index ->
                dir = get_dir_change(path |> Enum.at(index - 1), {x, y})
                dir
            end
        end
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end
end
