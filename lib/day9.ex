defmodule Day9 do
  use Utils.DayBoilerplate, day: 9

  def sample_input do
    """
    R 4
    U 4
    L 3
    D 1
    R 4
    D 1
    L 5
    R 2
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(fn line ->
      [a, b] = String.split(line, " ")
      {String.to_atom(a), String.to_integer(b)}
    end)
  end

  def step({x, y}, dir) do
    case dir do
      :U -> {x, y + 1}
      :D -> {x, y - 1}
      :L -> {x - 1, y}
      :R -> {x + 1, y}
    end
  end

  def add_move_to_steps({dir, dist}, moves) do
    moves ++ for _ <- 1..dist, do: dir
  end

  def do_moves({hpos, tpos}, [], visited), do: visited

  def do_moves({hpos, tpos}, [cur | moves], visited) do
    new_hpos = step(hpos, cur)
    new_tpos = move_tail(hpos, tpos)
    display_snake([new_hpos, new_tpos])
    do_moves({new_hpos, new_tpos}, moves, [new_tpos | visited])
  end

  def distance(p1, p2) do
    abs(p1.x - p2.x) + abs(p1.y - p2.y)
  end

  def move_tail({hx, hy}, {tx, ty}) do
    dx = hx - tx
    dy = hy - ty

    case {dx, dy} do
      {2, 2} ->
        {tx + 1, ty + 1}

      {2, -2} ->
        {tx + 1, ty - 1}

      {-2, 2} ->
        {tx - 1, ty + 1}

      {-2, -2} ->
        {tx - 1, ty - 1}

      {0, 2} ->
        {tx, ty + 1}

      {0, -2} ->
        {tx, ty - 1}

      {2, 0} ->
        {tx + 1, ty}

      {-2, 0} ->
        {tx - 1, ty}

      {1, 2} ->
        {tx + 1, ty + 1}

      {1, -2} ->
        {tx + 1, ty - 1}

      {2, 1} ->
        {tx + 1, ty + 1}

      {-2, 1} ->
        {tx - 1, ty + 1}

      {-1, 2} ->
        {tx - 1, ty + 1}

      {-1, -2} ->
        {tx - 1, ty - 1}

      {2, -1} ->
        {tx + 1, ty - 1}

      {-2, -1} ->
        {tx - 1, ty - 1}

      _ ->
        {tx, ty}
    end
  end

  def solve(input) do
    moves = input |> Enum.reduce([], &add_move_to_steps/2)

    do_moves({{0, 0}, {0, 0}}, moves, [{0, 0}])
    |> MapSet.new()
    |> MapSet.size()
  end

  def do_moves2(_, [], visited), do: visited

  def do_moves2([h | rest], [cur | moves], visited) do
    new_h = step(h, cur)

    new_rest =
      Enum.reduce(rest, [new_h], fn x, acc ->
        [move_tail(hd(acc), x) | acc]
      end)
      |> Enum.reverse()

    tail = Enum.at(new_rest, -1)

    display_snake(new_rest)
    do_moves2(new_rest, moves, [tail | visited])
  end

  def display_snake(snake) do
    min_x = 0
    max_x = Enum.max_by(snake, &elem(&1, 0)) |> elem(0)
    min_y = 0
    max_y = Enum.max_by(snake, &elem(&1, 1)) |> elem(1)

    disp =
      snake
      |> Enum.with_index()
      |> Map.new()

    output_str =
      min_y..max_y
      |> Enum.map(fn y ->
        min_x..max_x
        |> Enum.map(fn x ->
          o = Map.get(disp, {x, y}, ".")
          if o == 0, do: "H", else: o
        end)
        |> Enum.join("")
      end)
      |> Enum.reverse()
      |> Enum.join("\n")

    IO.puts(output_str)
    IO.puts("")
  end

  def solve2(input) do
    moves = input |> Enum.reduce([], &add_move_to_steps/2)

    initial = for _ <- 1..10, do: {0, 0}

    do_moves2(initial, moves, [{0, 0}])
    |> MapSet.new()
    |> MapSet.size()
  end
end
