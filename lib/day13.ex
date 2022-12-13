defmodule Day13 do
  use Utils.DayBoilerplate, day: 13

  def sample_input do
    """
    [1,1,3,1,1]
    [1,1,5,1,1]

    [[1],[2,3,4]]
    [[1],4]

    [9]
    [[8,7,6]]

    [[4,4],4,4]
    [[4,4],4,4,4]

    [7,7,7,7]
    [7,7,7]

    []
    [3]

    [[[]]]
    [[]]

    [1,[2,[3,[4,[5,6,7]]]],8,9]
    [1,[2,[3,[4,[5,6,0]]]],8,9]
    """
  end

  def parse_input(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(&parse_pair/1)
  end

  def parse_pair(pair) do
    pair
    |> String.split("\n", trim: true)
    |> Enum.map(&Code.eval_string/1)
    |> Enum.map(&elem(&1, 0))
  end

  def log_compare(a, b, indent) do
    IO.puts(
      String.duplicate(" ", indent * 2) <>
        "- " <>
        "Compare #{inspect(a, charlists: :as_lists)} vs #{inspect(b, charlists: :as_lists)}"
    )
  end

  def log_result(res, indent) do
    case res do
      :eq ->
        nil

      :lt ->
        IO.puts(
          String.duplicate(" ", (indent + 1) * 2) <>
            "- " <> "Left side is smaller, so inputs are in the right order"
        )

      :gt ->
        IO.puts(
          String.duplicate(" ", (indent + 1) * 2) <>
            "- " <> "Right side is smaller, so inputs are not in the right order"
        )
    end
  end

  def comp(a, b, indent) when is_integer(a) and is_integer(b) do
    log_compare(a, b, indent)

    case {a, b} do
      {a, b} when a == b ->
        :eq

      {a, b} when a > b ->
        log_result(:gt, indent)
        :gt

      {a, b} when a < b ->
        log_result(:lt, indent)
        :lt
    end
  end

  def comp(a, b, indent) when is_list(a) and is_integer(b) do
    log_compare(a, b, indent)
    comp(a, [b], indent + 1)
  end

  def comp(a, b, indent) when is_list(b) and is_integer(a) do
    log_compare(a, b, indent)
    comp([a], b, indent + 1)
  end

  def comp([], [], indent) do
    log_compare([], [], indent)
    #    log_result(:gt, indent)
    :eq
  end

  def comp([], [b | brest], indent) do
    log_compare([], [b | brest], indent)
    log_result(:lt, indent)
    :lt
  end

  def comp([a | arest], [], indent) do
    log_compare([a | arest], [], indent)
    log_result(:gt, indent)
    :gt
  end

  def comp([a | arest], [b | brest], indent) do
    log_compare([a | arest], [b | brest], indent)
    result = comp(a, b, indent + 1)

    case result do
      :eq -> comp(arest, brest, indent + 1)
      x -> x
    end
  end

  def solve(input) do
    input
    |> Enum.with_index()
    |> Enum.map(fn {[a, b], i} ->
      IO.puts("\n== Pair #{i + 1} ==")
      {comp(a, b, 0), i}
    end)
    |> Enum.filter(fn {dir, _} -> dir == :lt end)
    |> Enum.map(fn {_, i} -> i + 1 end)
    |> Enum.sum()
  end

  def solve2(input) do
    d1 = [[6]]
    d2 = [[2]]

    sorted = input ++ [[d1, d2]]
    |> Enum.flat_map(& &1)
    |> Enum.sort_by(& &1, fn a, b ->
      case comp(a, b, 0) do
        :eq -> true
        :lt -> true
        :gt -> false
      end
    end)

    a = Enum.find_index(sorted, fn x -> x == d1 end) + 1
    b = Enum.find_index(sorted, fn x -> x == d2 end) + 1

    a * b
  end
end
