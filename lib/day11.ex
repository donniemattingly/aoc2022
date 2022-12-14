defmodule Day11 do
  defmodule MonkeyCounter do
    def start_link(initial_state) do
      Task.start_link(fn -> loop(initial_state) end)
    end

    def loop(state) do
      receive do
        {:increment, key} ->
          new_state = Map.update(state, key, 1, &(&1 + 1))
          loop(new_state)

        {:get, caller} ->
          send(caller, state)
          loop(state)

        _ ->
          loop(state)
      end
    end
  end

  use Utils.DayBoilerplate, day: 11

  def sample_input do
    """
    Monkey 0:
      Starting items: 79, 98
      Operation: new = old * 19
      Test: divisible by 23
        If true: throw to monkey 2
        If false: throw to monkey 3

    Monkey 1:
      Starting items: 54, 65, 75, 74
      Operation: new = old + 6
      Test: divisible by 19
        If true: throw to monkey 2
        If false: throw to monkey 0

    Monkey 2:
      Starting items: 79, 60, 97
      Operation: new = old * old
      Test: divisible by 13
        If true: throw to monkey 1
        If false: throw to monkey 3

    Monkey 3:
      Starting items: 74
      Operation: new = old + 3
      Test: divisible by 17
        If true: throw to monkey 0
        If false: throw to monkey 1
    """
  end

  def parse_input(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(&parse_monkey/1)
    |> Enum.reduce({%{}, %{}}, fn monkey, {monkeys, items} ->
      {
        Map.put(monkeys, monkey[:name], Map.delete(monkey, :items)),
        Map.put(items, monkey[:name], monkey[:items])
      }
    end)
  end

  def parse_monkey(monkey) do
    monkey
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_attribute/1)
    |> Map.new()
  end

  def parse_attribute("Monkey " <> id) do
    {:name,
     id
     |> String.replace(":", "")
     |> String.to_integer()}
  end

  def parse_attribute("  Starting items: " <> items) do
    {:items,
     items
     |> String.split(", ")
     |> Enum.map(&String.to_integer/1)}
  end

  def parse_attribute("  Operation: new = " <> op) do
    {fun, _} = Code.eval_string("fn old -> #{op} end")
    {:operation, fun}
  end

  def parse_attribute("  Test: divisible by " <> test) do
    {:test, test}
  end

  def do_test(old, test) do
    rem(old, String.to_integer(test)) == 0
  end

  def parse_attribute("    If true: throw to monkey " <> id) do
    {true, id |> String.to_integer()}
  end

  def parse_attribute("    If false: throw to monkey " <> id) do
    {false, id |> String.to_integer()}
  end

  def bored(level), do: div(level, 3)

  def run_round(a, b, c, d \\ nil)
  def run_round(items, [], _, _shared_div), do: items

  def run_round(items, [m | monkeys], counter, shared_div) do
    case Map.get(items, m[:name]) do
      [] ->
        run_round(items, monkeys, counter, shared_div)

      [item | rest] ->
        new_val =
          case shared_div do
            nil ->
              item |> m[:operation].() |> bored()

            _ ->
              item
              |> m[:operation].()
              |> rem(shared_div)
          end

        throw_to =
          case rem(new_val, String.to_integer(m[:test])) == 0 do
            true -> m[true]
            false -> m[false]
          end

        send(counter, {:increment, m[:name]})

        new_items =
          items
          |> Map.put(m[:name], rest)
          |> Map.update(throw_to, [new_val], &(&1 ++ [new_val]))

        case rest do
          [] -> run_round(new_items, monkeys, counter, shared_div)
          _ -> run_round(new_items, [m | monkeys], counter, shared_div)
        end
    end
  end

  def do_times(times, fun) do
    Enum.reduce(1..times, nil, fn _, _ -> fun.() end)
  end

  def solve(input) do
    {monkeys, items} = input
    counter_state = monkeys |> Map.keys() |> Enum.map(&{&1, 0}) |> Map.new()
    {:ok, counter} = MonkeyCounter.start_link(counter_state)

    mlist = Map.values(monkeys)

    1..20
    |> Enum.reduce(items, fn _, items ->
      run_round(items, mlist, counter)
    end)

    send(counter, {:get, self()})

    receive do
      state ->
        state
        |> Map.values()
        |> Enum.sort()
        |> Enum.reverse()
        |> Enum.take(2)
        |> Enum.reduce(1, &(&1 * &2))
    end
  end

  def solve2(input) do
    {monkeys, items} = input
    counter_state = monkeys |> Map.keys() |> Enum.map(&{&1, 0}) |> Map.new()
    {:ok, counter} = MonkeyCounter.start_link(counter_state)

    mlist = Map.values(monkeys)

    shared_div =
      mlist
      |> Enum.map(fn m -> String.to_integer(m[:test]) end)
      |> Enum.reduce(&Kernel.*/2)
      |> IO.inspect()

    1..10_000
    |> Enum.reduce(items, fn count, items ->
      #      IO.puts("Round #{count}")
      run_round(items, mlist, counter, shared_div)
    end)

    send(counter, {:get, self()})

    receive do
      state ->
        state
        |> Map.values()
        |> Enum.sort()
        |> Enum.reverse()
        |> Enum.take(2)
        |> Enum.reduce(1, &(&1 * &2))
    end
  end
end
