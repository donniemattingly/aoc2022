defmodule Day8 do
  use Utils.DayBoilerplate, day: 8

  def sample_input do
    """
    30373
    25512
    65332
    33549
    35390
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(fn line -> line |> Utils.split_each_char() |> Enum.map(&String.to_integer/1) end)
  end

  def solve(input) do
    size = length(input)
    map = Utils.list_of_lists_to_map_by_point(input)

    map
    |> Map.to_list()
    |> Enum.map(fn {point, value} -> is_visible?(map, size, point) end)
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  def is_visible?(_, length, {x, y}) when x == 0 or x == length - 1 or y == 0 or y == length - 1,
    do: true

  def is_visible?(map, length, point = {x, y}) do
    from_left = for dx <- 0..(x - 1), do: Map.get(map, {dx, y})
    from_right = for dx <- (length - 1)..(x + 1), do: Map.get(map, {dx, y})
    from_bottom = for dy <- (length - 1)..(y + 1), do: Map.get(map, {x, dy})
    from_top = for dy <- 0..(y - 1), do: Map.get(map, {x, dy})

    visible =
      [from_left, from_right, from_bottom, from_top]
      |> Enum.filter(fn x -> Enum.all?(x, fn p -> Map.get(map, point) > p end) end)
      |> Enum.count()
      |> Kernel.>(0)

    visible
  end

  def solve2(input) do
    size = length(input)
    map = Utils.list_of_lists_to_map_by_point(input)

    map
    |> Map.to_list()
    |> Enum.map(fn {point, value} -> {point, get_scenic_score(map, size, point)} end)
    |> Enum.max_by(fn {_point, score} -> score end)
  end

  def get_scenic_score(map, length, point = {x, y}) do
    IO.puts("\npoint: #{inspect(point)} with value: #{Map.get(map, point)}")
    to_left = for dx <- x..0, do: Map.get(map, {dx, y})
    to_right = for dx <- x..(length - 1), do: Map.get(map, {dx, y})
    to_bottom = for dy <- y..(length - 1), do: Map.get(map, {x, dy})
    to_top = for dy <- y..0, do: Map.get(map, {x, dy})

    IO.inspect({to_left, to_right, to_bottom, to_top})

    score =
      [to_left, to_right, to_bottom, to_top]
      |> Enum.map(&get_score_in_direction(map, &1, point))
      |> Enum.reduce(&Kernel.*/2)

    IO.puts("score: #{score}")
    score
  end

  def get_score_in_direction(_, nil, _), do: 0

  def get_score_in_direction(map, direction, point) do
    IO.inspect(direction, label: "direction")

    case direction
         |> Enum.drop(1)
         |> Enum.reduce_while([], fn x, acc ->
           if x < Map.get(map, point) do
             {:cont, [x | acc]}
           else
             {:halt, [x | acc]}
           end
         end)
         |> IO.inspect(label: "drop and take")
         |> Enum.count() do
      0 -> 0
      n -> n
    end
    |> IO.inspect(label: "direction score")
  end
end
