defmodule Day10 do
  use Utils.DayBoilerplate, day: 10

  def sample_input do
    """
    addx 15
    addx -11
    addx 6
    addx -3
    addx 5
    addx -1
    addx -8
    addx 13
    addx 4
    noop
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx -35
    addx 1
    addx 24
    addx -19
    addx 1
    addx 16
    addx -11
    noop
    noop
    addx 21
    addx -15
    noop
    noop
    addx -3
    addx 9
    addx 1
    addx -3
    addx 8
    addx 1
    addx 5
    noop
    noop
    noop
    noop
    noop
    addx -36
    noop
    addx 1
    addx 7
    noop
    noop
    noop
    addx 2
    addx 6
    noop
    noop
    noop
    noop
    noop
    addx 1
    noop
    noop
    addx 7
    addx 1
    noop
    addx -13
    addx 13
    addx 7
    noop
    addx 1
    addx -33
    noop
    noop
    noop
    addx 2
    noop
    noop
    noop
    addx 8
    noop
    addx -1
    addx 2
    addx 1
    noop
    addx 17
    addx -9
    addx 1
    addx 1
    addx -3
    addx 11
    noop
    noop
    addx 1
    noop
    addx 1
    noop
    noop
    addx -13
    addx -19
    addx 1
    addx 3
    addx 26
    addx -30
    addx 12
    addx -1
    addx 3
    addx 1
    noop
    noop
    noop
    addx -9
    addx 18
    addx 1
    addx 2
    noop
    noop
    addx 9
    noop
    noop
    noop
    addx -1
    addx 2
    addx -37
    addx 1
    addx 3
    noop
    addx 15
    addx -21
    addx 22
    addx -6
    addx 1
    noop
    addx 2
    addx 1
    noop
    addx -10
    noop
    noop
    addx 20
    addx 1
    addx 2
    addx 2
    addx -6
    addx -11
    noop
    noop
    noop
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    case String.split(line, " ") do
      ["noop"] -> :noop
      ["addx", x] -> {:addx, String.to_integer(x)}
    end
  end

  def do_run_cycles([], state), do: state

  def do_run_cycles([cur | rest], {signal, instr_count, record, pending_instructions}) do
    new_count = instr_count + 1

    new_pending =
      case cur do
        :noop -> [{cur, 1} | pending_instructions]
        {:addx, _} -> [{cur, 2} | pending_instructions]
      end

    new_record = [{new_count, signal} | record]

    {resolve, unresolved} =
      new_pending
      |> Enum.map(fn {instr, count} -> {instr, count - 1} end)
      |> Enum.split_with(fn {_, count} -> count == 0 end)

    new_signal =
      case resolve do
        [{:noop, 0}] -> signal
        [{{:addx, x}, 0}] -> signal + x
        _ -> signal
      end

    do_run_cycles(rest, {new_signal, new_count, new_record, unresolved})
  end

  def run_cycles(instructions) do
    do_run_cycles(instructions, {1, 0, [], []})
  end

  def get_signal(input) do
    {_, _, record} =
      input
      |> Enum.reduce({1, 1, %{}}, fn
        :noop, {signal, count, record} ->
          {signal, count + 1, Map.put(record, count + 1, signal)}

        {:addx, x}, {signal, count, record} ->
          {signal + x, count + 2,
           record |> Map.put(count + 1, signal) |> Map.put(count + 2, signal + x)}
      end)

    record
  end

  def solve(input) do
    record = get_signal(input)

    20..220//40
    |> Enum.map(&(&1 * Map.get(record, &1)))
    |> Enum.sum()
  end

  def solve2(input) do
    record = get_signal(input)

    1..240
    |> Enum.map(&{&1 - 1, Map.get(record, &1, 1)})
    |> Enum.map(fn {cycle, signal} ->
      col = rem(cycle, 40)

      str =
        case abs(signal - col) do
          0 -> "#"
          1 -> "#"
          _ -> "."
        end

      if col == 0, do: str <> "\n", else: str
    end)
  end
end
