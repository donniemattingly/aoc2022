defmodule Day18 do
  use Utils.DayBoilerplate, day: 18

  use Memoize

  def sample_input do
    """
    2,2,2
    1,2,2
    3,2,2
    2,1,2
    2,3,2
    2,2,1
    2,2,3
    2,2,4
    2,2,6
    1,2,5
    3,2,5
    2,1,5
    2,3,5
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn x -> Enum.map(x, &String.to_integer/1) |> List.to_tuple() end)
  end

  def adjacent_points({x, y, z}) do
    [
      {x - 1, y, z},
      {x + 1, y, z},
      {x, y - 1, z},
      {x, y + 1, z},
      {x, y, z - 1},
      {x, y, z + 1}
    ]
  end

  def bounding_box(cubes) do
    min_x = cubes |> Enum.map(fn {x, _, _} -> x end) |> Enum.min() |> Kernel.+(-1)
    min_y = cubes |> Enum.map(fn {_, y, _} -> y end) |> Enum.min() |> Kernel.+(-1)
    min_z = cubes |> Enum.map(fn {_, _, z} -> z end) |> Enum.min() |> Kernel.+(-1)
    max_x = cubes |> Enum.map(fn {x, _, _} -> x end) |> Enum.max() |> Kernel.+(1)
    max_y = cubes |> Enum.map(fn {_, y, _} -> y end) |> Enum.max() |> Kernel.+(1)
    max_z = cubes |> Enum.map(fn {_, _, z} -> z end) |> Enum.max() |> Kernel.+(1)
    {min_x, max_x, min_y, max_y, min_z, max_z}
  end

  def solve(input) do
    cubes = MapSet.new(input)

    input
    |> Enum.map(&adjacent_points/1)
    |> Enum.flat_map(fn x -> Enum.map(x, &MapSet.member?(cubes, &1)) end)
    |> Enum.reject(& &1)
    |> length
  end

  def fill(cubes, {min_x, max_x, min_y, max_y, min_z, max_z}) do
  end

  def get_adjacent_water_cubes(cubes, [], _), do: cubes

  def get_adjacent_water_cubes(
        cubes,
        points,
        bounds = {min_x, max_x, min_y, max_y, min_z, max_z}
      ) do

    new_adjacent =
      points
      |> Stream.flat_map(&adjacent_points/1)
      |> Stream.uniq()
      |> Stream.filter(fn {x, y, z} ->
        x >= min_x and x <= max_x and y >= min_y and y <= max_y and z >= min_z and z <= max_z
      end)
      |> Stream.filter(fn point -> not Map.has_key?(cubes, point) end)
      |> Enum.to_list()

    new_cubes = Map.merge(cubes, Map.new(new_adjacent, fn x -> {x, :water} end))
    get_adjacent_water_cubes(new_cubes, new_adjacent, bounds)
  end

  def solve2(input) do
    cubes = input |> Enum.map(fn x -> {x, :lava} end) |> Map.new()

    bounds = {min_x, max_x, min_y, max_y, min_z, max_z} = bounding_box(input)

    #    get_adjacent_water_cubes(cubes, [{min_x, min_y, min_z}], bounds)
    updated = get_adjacent_water_cubes(cubes, [{1, 0, 0}, {0, 1, 0}, {0, 0, 1}], bounds)

    input
    |> Enum.map(&adjacent_points/1)
    |> Enum.flat_map(fn x -> Enum.map(x, fn p -> {p, Map.get(updated, p)} end) end)
    |> Enum.filter(fn {_, v} -> v == :water end)
    |> length()
  end
end
