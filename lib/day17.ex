defmodule Day17 do
  use Utils.DayBoilerplate, day: 17

  def sample_input do
    """
    >>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_each_char()
    |> Enum.map(fn
      ">" -> :right
      "<" -> :left
    end)
  end

  def print_cave(grid_map) do
    {min_x, max_x} = Day14.min_max_of_grid(grid_map, 0)
    {min_y, max_y} = Day14.min_max_of_grid(grid_map, 1)

    IO.puts("")

    Enum.map(max_y..-1, fn y ->
      Enum.map(-1..7, fn x ->
        case {x, y} do
          {-1, _} ->
            "|"

          {7, _} ->
            "|"

          {_, -1} ->
            "-"

          {x, y} ->
            case Map.get(grid_map, {x, y}) do
              :moving -> "@"
              :static -> "#"
              _ -> "."
            end
        end
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def tiles do
    """
    ####

    .#.
    ###
    .#.

    ..#
    ..#
    ###

    #
    #
    #
    #

    ##
    ##
    """
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_tile/1)
  end

  def parse_tile(tile) do
    tile
    |> Utils.split_lines()
    |> Enum.reverse()
    |> Enum.map(fn line ->
      line
      |> Utils.split_each_char()
      |> Enum.map(fn
        "#" -> :moving
        x -> nil
      end)
    end)
    |> Utils.list_of_lists_to_map_by_point()
    |> Map.to_list()
    |> Enum.filter(fn {k, v} -> v != nil end)
    |> Map.new()
  end

  def move(tile, direction, amount \\ 1) do
    tlist = Map.to_list(tile)

    case direction do
      :up -> Map.new(tlist, fn {{x, y}, v} -> {{x, y + amount}, v} end)
      :down -> Map.new(tlist, fn {{x, y}, v} -> {{x, y - amount}, v} end)
      :left -> Map.new(tlist, fn {{x, y}, v} -> {{x - amount, y}, v} end)
      :right -> Map.new(tlist, fn {{x, y}, v} -> {{x + amount, y}, v} end)
    end
  end

  def can_move(cave, moving, direction) do
    next_pos = move(moving, direction)

    tiles_block =
      Map.keys(next_pos)
      |> Enum.any?(fn point ->
        Map.has_key?(cave, point)
      end)

    walls_block =
      Map.keys(next_pos)
      |> Enum.any?(fn {x, y} ->
        x < 0 or x > 6 or y < 0
      end)

#    IO.inspect({tiles_block, walls_block}, label: "blocked? (tiles, walls)")
    not tiles_block and not walls_block
  end

  def place_next_moving_tile(cave, tile_template) do
    highest_point =
      case cave |> Map.keys() |> Enum.map(&elem(&1, 1)) do
        [] -> -1
        l -> Enum.max(l)
      end

    tile_size = tile_template |> Map.keys() |> Enum.max_by(&elem(&1, 1)) |> elem(1) |> Kernel.+(1)

    #    IO.inspect({highest_point, tile_size}, label: "highest_point, tile_size")

    next_y = highest_point + 4

    tile_template
    |> move(:up, next_y)
    |> move(:right, 2)
  end

  @stop 200


  def do_move(_moves, _tile_templates, cave, _moving_tile, _next_tile, _next_move, @stop),
    do: cave

  def do_move(moves, tile_templates, acc_cave, moving_tile, next_tile, next_move, tiles_dropped) do
    #    IO.inspect(tiles_dropped, label: "tiles_dropped")
    move_index = rem(next_move, length(moves))
    move = Enum.at(moves, move_index)

#    print_cave(Map.merge(acc_cave, moving_tile))
#    IO.inspect({move, move_index}, label: "move")
#    IO.inspect({next_tile, next_move, length(moves)}, label: "next_tile, next_move")

    case {move, can_move(acc_cave, moving_tile, move)} do
      {:left, false} ->
        do_move(
          moves,
          tile_templates,
          acc_cave,
          moving_tile,
          next_tile,
          next_move + 1,
          tiles_dropped
        )

      {:right, false} ->
        do_move(
          moves,
          tile_templates,
          acc_cave,
          moving_tile,
          next_tile,
          next_move + 1,
          tiles_dropped
        )

      {_, true} ->
        do_move(
          moves,
          tile_templates,
          acc_cave,
          move(moving_tile, move),
          next_tile,
          next_move + 1,
          tiles_dropped
        )

      {:down, false} ->
        new_cave =
          moving_tile
          |> Map.to_list()
          |> Enum.map(fn {k, v} -> {k, :static} end)
          |> Map.new()
          |> Map.merge(acc_cave)

        new_moving_tile = place_next_moving_tile(new_cave, tile_templates |> Enum.at(next_tile))

        if(true) do
          height = new_cave
                   |> Map.keys()
                   |> Enum.max_by(&elem(&1, 1))
                   |> elem(1)

          IO.puts("#{tiles_dropped}, #{height + 1}")
        end
#        IO.puts("New Tile")
#        print_cave(Map.merge(new_cave, new_moving_tile))

        do_move(
          moves,
          tile_templates,
          new_cave,
          new_moving_tile,
          rem(next_tile + 1, 5),
          next_move + 1,
          tiles_dropped + 1
        )
    end
  end

  def solve(input) do
    cave = %{}
    tile_templates = tiles()
    first = place_next_moving_tile(cave, tile_templates |> Enum.at(0))
    moves = (input |> Enum.intersperse(:down)) ++ [:down]

    do_move(moves, tile_templates, cave, first, 1, 0, 1)
    |> Map.keys()
    |> Enum.max_by(&elem(&1, 1))
  end
end
