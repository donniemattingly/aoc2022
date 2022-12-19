defmodule Day15 do
  use Utils.DayBoilerplate, day: 15
  use Memoize

  def sample_input do
    """
    Sensor at x=2, y=18: closest beacon is at x=-2, y=15
    Sensor at x=9, y=16: closest beacon is at x=10, y=16
    Sensor at x=13, y=2: closest beacon is at x=15, y=3
    Sensor at x=12, y=14: closest beacon is at x=10, y=16
    Sensor at x=10, y=20: closest beacon is at x=10, y=16
    Sensor at x=14, y=17: closest beacon is at x=10, y=16
    Sensor at x=8, y=7: closest beacon is at x=2, y=10
    Sensor at x=2, y=0: closest beacon is at x=2, y=10
    Sensor at x=0, y=11: closest beacon is at x=2, y=10
    Sensor at x=20, y=14: closest beacon is at x=25, y=17
    Sensor at x=17, y=20: closest beacon is at x=21, y=22
    Sensor at x=16, y=7: closest beacon is at x=15, y=3
    Sensor at x=14, y=3: closest beacon is at x=15, y=3
    Sensor at x=20, y=1: closest beacon is at x=15, y=3
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [[_, sx, sy, bx, by]] =
      Regex.scan(
        ~r/Sensor at x=([\d|-]+), y=([\d|-]+): closest beacon is at x=([\d|-]+), y=([\d|-]+)/,
        line
      )

    {{String.to_integer(sx), String.to_integer(sy)},
     {String.to_integer(bx), String.to_integer(by)}}
  end

  def manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def sensor_with_range({sensor, beacon}) do
    {sensor, manhattan_distance(sensor, beacon)}
  end

  def point_in_range?(point, {sensor, range}) do
    d = manhattan_distance(point, sensor)
    d <= range
  end

  def solve(input) do
    {min_y, max_y} =
      input
      |> Enum.flat_map(fn {{x1, y1}, {x2, y2}} ->
        {_, r} = sensor_with_range({{x1, y1}, {x2, y2}})
        [y1, y1 + r, y1 - r, y2, y2 + r, y2 - r]
      end)
      |> Enum.min_max()

    {min_x, max_x} =
      input
      |> Enum.flat_map(fn {{x1, y1}, {x2, y2}} ->
        {_, r} = sensor_with_range({{x1, y1}, {x2, y2}})
        [x1, x1 + r, x1 - r, x2, x2 + r, x2 - r]
      end)
      |> Enum.min_max()

    ranges =
      input
      |> Enum.map(&sensor_with_range/1)

    min_x..max_x
    |> Enum.map(fn x -> {x, 2_000_000} end)
    |> Enum.filter(fn point ->
      ranges
      |> Enum.any?(&point_in_range?(point, &1))
    end)
    |> Enum.count()
  end

  def solve2(input) do
    {min_y, max_y} =
      input
      |> Enum.flat_map(fn {{x1, y1}, {x2, y2}} ->
        {_, r} = sensor_with_range({{x1, y1}, {x2, y2}})
        [y1, y1 + r, y1 - r, y2, y2 + r, y2 - r]
      end)
      |> Enum.min_max()

    {min_x, max_x} =
      input
      |> Enum.flat_map(fn {{x1, y1}, {x2, y2}} ->
        {_, r} = sensor_with_range({{x1, y1}, {x2, y2}})
        [x1, x1 + r, x1 - r, x2, x2 + r, x2 - r]
      end)
      |> Enum.min_max()

    ranges =
      input
      |> Enum.map(&sensor_with_range/1)

    ranges
    |> adjust_ranges()
  end

  def remove_area(ranges, {a, b}) do
    # Iterate over the ranges
    {new_ranges, _} =
      ranges
      |> Enum.reduce({[], {a, b}}, fn
        x, {acc, nil} ->
          {[x | acc], nil}

        {r1, r2}, {acc_ranges, {a1, a2}} ->
          cond do
            # r1 r2 a1 a2 - no overlap
            r1 < a1 and r2 < a1 ->
              {[{r1, r2} | acc_ranges], {a1, a2}}

            # a1 a2 r1 r2 - no overlap
            r1 > a2 and r2 > a2 ->
              {[{r1, r2} | acc_ranges], {a1, a2}}

            # r1 a1 a2 r2 - contained
            r1 < a1 and r2 > a2 ->
              {[{a2, r2}, {r1, a1} | acc_ranges], nil}

            # r1 a1 r2 a2 - overlap
            r1 < a1 and r2 > a1 and r2 < a2 ->
              {[{r1, a1} | acc_ranges], {r2, a2}}

            # a1 r1 a2 r2
            r1 > a1 and r1 < a2 and r2 > a2 ->
              {[{a2, r2} | acc_ranges], nil}

            true ->
              {acc_ranges, {a1, a2}}
          end
      end)

    new_ranges
    |> Enum.reverse()

    # If the range is entirely before the area to remove, add it to the result list
    # If the range is entirely after the area to remove, add it to the result list
    # If the range overlaps the area to remove, add the parts that are not in the area to remove
  end

  def do_adjust_ranges(xs, ys, []), do: {xs, ys}

  def do_adjust_ranges(xs, ys, [{{x, y}, range} | rest]) do
    remove_x = {x - range, x + range}
    remove_y = {y - range, y + range}

    new_xs = remove_area(xs, remove_x) |> IO.inspect(label: "xs")
    new_ys = remove_area(ys, remove_y) |> IO.inspect(label: "ys")

    do_adjust_ranges(new_xs, new_ys, rest)
    #    [new_xs, new_ys]
  end

  def adjust_ranges(ranges) do
    do_adjust_ranges([{0, 20}], [{0, 20}], ranges)
  end

  def notes do
    """
    I have a lazy stream of all the points in the range of the sensors, I plan to
    filter that stream to only include points that are in range of all the sensors.

    using the map of sensors to ranges, I can filter the stream to only include
    """
  end
end
