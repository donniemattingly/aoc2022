defmodule Day21 do
  use Utils.DayBoilerplate, day: 21

  def sample_input do
    """
    root: pppw + sjmn
    dbpl: 5
    cczh: sllz + lgvd
    zczc: 2
    ptdq: humn - dvpt
    dvpt: 3
    lfqf: 4
    humn: 5
    ljgn: 2
    sjmn: drzm * dbpl
    sllz: 4
    pppw: cczh / lfqf
    lgvd: ljgn * ptdq
    drzm: hmdt - zczc
    hmdt: 32
    """
  end

  def parse_line(line) do
    [str_name, value] = String.split(line, ": ")
    name = String.to_atom(str_name)

    case Regex.scan(~r/(\w+) ([\+|\-|\*|\/]) (\w+)/, value) do
      [] -> {name, String.to_integer(value)}
      [[_, m1, op, m2]] -> {name, {String.to_atom(m1), op, String.to_atom(m2)}}
    end
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(&parse_line/1)
  end

  def do_math([], monkey_vals, _), do: monkey_vals

  def do_math(un_processed, monkey_vals, monkey_map) do
    cur_monkey =
      Enum.find(un_processed, fn monkey ->
        case monkey_map[monkey] do
          {m1, op, m2} -> Map.has_key?(monkey_vals, m1) and Map.has_key?(monkey_vals, m2)
          v when is_integer(v) -> true
        end
      end)

    #      |> IO.inspect()

    new_vals =
      case {cur_monkey, monkey_map[cur_monkey]} do
        {:root, {m1, _, m2}} ->
          m1_val = monkey_vals[m1]
          m2_val = monkey_vals[m2]
          {m1_val, m2_val}

        {_, {m1, op, m2}} ->
          #          IO.puts("Doing #{cur_monkey} = #{m1} #{op} #{m2}")
          m1_val = monkey_vals[m1]
          m2_val = monkey_vals[m2]

          case op do
            "+" -> Map.put(monkey_vals, cur_monkey, m1_val + m2_val)
            "-" -> Map.put(monkey_vals, cur_monkey, m1_val - m2_val)
            "*" -> Map.put(monkey_vals, cur_monkey, m1_val * m2_val)
            "/" -> Map.put(monkey_vals, cur_monkey, m1_val / m2_val)
          end

        {_, value} ->
          Map.put(monkey_vals, cur_monkey, value)
      end

    do_math(Enum.reject(un_processed, &(&1 == cur_monkey)), new_vals, monkey_map)
  end

  def solve(input) do
    monkey_map = input |> Enum.into(%{})

    do_math(Map.keys(monkey_map), %{}, monkey_map)
    |> Map.get(:root)
  end

  def sublist?([], _), do: false

  def sublist?(l1 = [_ | t], l2) do
    List.starts_with?(l1, l2) or sublist?(t, l2)
  end

  def solve2(input) do
    monkey_map = input |> Enum.into(%{})

    orig = monkey_map[:humn]

    start = 3_305_669_214_000

    #    -1_000..1_000//100
    #    |> Enum.map(fn i ->
    #      monkey_map = Map.put(monkey_map, :humn, orig + i + start)
    #
    #      {m1, m2} = do_math(Map.keys(monkey_map), %{}, monkey_map)
    #      abs(m1 - m2)
    #      |> :erlang.float_to_binary()
    #      |> IO.inspect(label: "abs(#{i + start})")
    #    end)

    monkey_map = Map.put(monkey_map, :humn, (orig + 3_305_669_213_700) |> IO.inspect())

    {m1, m2} = do_math(Map.keys(monkey_map), %{}, monkey_map)
    m1 - m2
#    |> Map.get(:root)
  end

  def solve2(input) do
    g =
      input
      |> Enum.reduce(Graph.new(), fn x, graph ->
        case x do
          {name, {m1, op, m2}} ->
            graph
            #            |> Graph.add_edge(m1, name)
            #            |> Graph.add_edge(m2, name)
            |> Graph.add_edge(name, m1)
            |> Graph.add_edge(name, m2)

          {name, value} ->
            Graph.add_vertex(graph, name)
        end
      end)

    paths =
      Graph.vertices(g)
      |> Enum.map(&Graph.get_shortest_path(g, :root, &1))

    #      |> Enum.filter(& &1)
    #      |> Enum.reject(fn path -> Enum.any?(path, fn vertex -> true end) end)
    #      |> Enum.sort_by(&length(&1))
    #      |> Enum.reverse()
    #      |> Enum.map(&Enum.reverse/1)
  end
end
