defmodule Day16 do
  use Utils.DayBoilerplate, day: 16

  defmodule PathProcess do
    def start_link(initial_state) do
      Task.start_link(fn -> loop(initial_state) end)
    end

    def loop({cur_path, cur_pressure, paths_seen} = state) do
      receive do
        {:new_path, {path, pressure}} ->
          if(cur_pressure <= pressure) do
            IO.puts("New path found")
            IO.inspect({path, pressure, paths_seen})
            IO.puts("")
            loop({path, pressure, paths_seen + 1})
          else
            if rem(paths_seen, 100_000) == 0, do: IO.write("\rSeen #{paths_seen} paths")
            loop({cur_path, cur_pressure, paths_seen + 1})
          end

        {:get, caller} ->
          send(caller, state)
          loop(state)

        _ ->
          loop(state)
      end
    end
  end

  def sample_input do
    """
    Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
    Valve BB has flow rate=13; tunnels lead to valves CC, AA
    Valve CC has flow rate=2; tunnels lead to valves DD, BB
    Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
    Valve EE has flow rate=3; tunnels lead to valves FF, DD
    Valve FF has flow rate=0; tunnels lead to valves EE, GG
    Valve GG has flow rate=0; tunnels lead to valves FF, HH
    Valve HH has flow rate=22; tunnel leads to valve GG
    Valve II has flow rate=0; tunnels lead to valves AA, JJ
    Valve JJ has flow rate=21; tunnel leads to valve II
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(&parse_line/1)
    |> Enum.map(fn valve -> {valve.name, valve} end)
    |> Map.new()
  end

  def parse_line(line) do
    line
    |> String.split(~r/ has flow rate=|; tunnels lead to valves |, |; tunnel leads to valve /)
    |> parse_valve()
  end

  def parse_valve(["Valve " <> name, flow_rate | connections]) do
    %{
      name: String.to_atom(name),
      flow_rate: String.to_integer(flow_rate),
      connections: connections |> Enum.map(&String.to_atom/1)
    }
  end

  def solve(input) do
    {:ok, path_process} = PathProcess.start_link({[], 0, 0})

    edges =
      input
      |> Map.values()
      |> Enum.flat_map(fn %{name: name, connections: connections, flow_rate: flow_rate} ->
        connections
        |> Enum.flat_map(fn connection ->
          [{name, connection}, {connection, name}]
        end)
      end)

    g = Graph.add_edges(Graph.new(), edges)

    non_zero_valves =
      input |> Map.values() |> Enum.filter(fn x -> x.flow_rate > 0 end) |> Enum.map(& &1[:name])

    nonzero_to_nonzero = Comb.selections(non_zero_valves, 2) |> Enum.to_list()
    start_to_nonzero = non_zero_valves |> Enum.map(fn x -> [:AA, x] end)

    path_map =
      (start_to_nonzero ++ nonzero_to_nonzero)
      |> Enum.filter(fn [a, b] -> a != b end)
      |> Enum.map(fn [a, b] ->
        {{a, b}, Graph.get_shortest_path(g, a, b)}
      end)
      |> Map.new()


    get_neighbor_paths(:AA, path_map)
    |> Enum.map(fn path ->
      {path, Map.get(path_map, path) |> cost_of_path()}
    end)

    do_step([:AA], path_map, input, MapSet.new(), 0, 0, path_process)
  end

  def get_neighbor_paths(valve, path_map) do
    path_map
    |> Map.keys()
    |> Enum.filter(fn {a, b} -> a == valve end)
  end

  def cost_of_path(path) do
    # length of path + 1 to open the valve
    length(path)
  end

  def get_released_steam(open_valves, valves, elapsed_time) do
    open_valves
    |> Enum.map(fn valve ->
      Map.get(valves, valve)
    end)
    |> Enum.map(fn %{flow_rate: flow_rate} ->
      flow_rate * elapsed_time
    end)
    |> Enum.sum()
  end

  def do_step(
        existing_path,
        path_map,
        valves,
        open_valves,
        released_pressure,
        time,
        path_process
      ) do
    #    IO.puts("")
    #    IO.inspect(time, label: "time")
    #    IO.inspect(open_valves, label: "open_valves")
    #    IO.inspect(existing_path, label: "existing_path")
    #    IO.inspect(released_pressure, label: "cur_pressure")
    # |> IO.inspect(label: "cur")
    cur = Enum.at(existing_path, 0)

    neighbors =
      get_neighbor_paths(cur, path_map)
      |> Enum.filter(fn {_, b} ->
        !MapSet.member?(open_valves, b)
      end)

    #      |> IO.inspect(label: "neighbors")

    if neighbors == [] do
      until_end = 31 - time
      total_steam = released_pressure + get_released_steam(open_valves, valves, until_end)
#      IO.puts("Found a path with #{total_steam} steam first if")
      send(path_process, {:new_path, {existing_path, total_steam}})
    else
      neighbors
      |> Enum.map(fn valve_pair ->
        path = Map.get(path_map, valve_pair)
        cost = cost_of_path(path)
        {valve_pair, path, cost}
      end)
      |> Enum.each(fn
        {{_, destination}, [_ | path], cost} when time + cost <= 30 ->
          #          IO.inspect({destination, path, cost}, label: "next step")
          new_open_valves = MapSet.put(open_valves, destination)

          new_released_pressure =
            released_pressure + get_released_steam(open_valves, valves, cost)

          #            |> IO.inspect(label: "released pressure")

          new_path = Enum.reverse(path) ++ existing_path

          do_step(
            new_path,
            path_map,
            valves,
            new_open_valves,
            new_released_pressure,
            time + cost,
            path_process
          )

        {{_, destination}, path, _} ->
          until_end = 30 - time

          total_steam =
            released_pressure +
              get_released_steam(MapSet.put(open_valves, destination), valves, until_end)

#          IO.puts("Found a path with #{total_steam} steam last if")
#          send(path_process, {:new_path, {path ++ existing_path, total_steam}})

#          until_end = 30 - time
#          total_steam = released_pressure + get_released_steam(open_valves, valves, until_end)
#          IO.puts("Found a path with #{total_steam} steam first if")
          send(path_process, {:new_path, {existing_path, total_steam}})
      end)
    end
  end
end
