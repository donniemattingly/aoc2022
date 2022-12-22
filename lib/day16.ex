defmodule Day16 do
  use Utils.DayBoilerplate, day: 16

  defmodule PathProcess do
    def start_link(initial_state) do
      Task.start_link(fn -> loop(initial_state) end)
    end

    def loop({cur_path, cur_pressure, paths_seen} = state) do
      receive do
        {:new_path, {path, pressure}} ->
          if(cur_pressure < pressure) do
            IO.puts("New path found")
            IO.inspect({path, pressure, paths_seen})
            loop({path, pressure, paths_seen + 1})
          else
          if rem(paths_seen, 100000) == 0, do: IO.write("\rSeen #{paths_seen} paths")
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
    %{name: name, flow_rate: String.to_integer(flow_rate), connections: connections}
  end

  def do_step(%{time: time} = state) when time == 30 do
    send(state.path_process, {:new_path, {state.path, state.released_pressure}})

    nil
  end

  def do_step(
        %{
          next_action: next_action,
          next_valve: next_valve,
          valves: valves,
          path: path,
          open_valves: open_valves,
          released_pressure: released_pressure,
          time: time
        } = state
      ) do

    new_pressure = update_pressure(released_pressure, open_valves, valves)
    new_open_valves = if next_action == :open, do: MapSet.put(open_valves, next_valve), else: open_valves
    connections = Map.get(valves, next_valve).connections
    open_move = if next_action == :open or MapSet.member?(open_valves, next_valve), do: [], else: [{:open, next_valve}]
    possible_actions = open_move ++ Enum.map(connections, &{:move, &1})
    possible_actions
    |> Enum.each(fn {action, valve} ->
      new_path = [{valve, action} | path]
      new_state = %{
        state
        | next_action: action,
          next_valve: valve,
          path: new_path,
          open_valves: new_open_valves,
          released_pressure: new_pressure,
          time: time + 1
      }

      do_step(new_state)
    end)
  end

  def step(valves, path_process) do
    do_step(%{path_process: path_process, valves: valves, next_action: :move, next_valve: "AA", path: [], open_valves: MapSet.new(), released_pressure: 0, time: 0})
  end

  def update_pressure(current_pressure, open_valves, valves) do
    open_valves
    |> Enum.map(&Map.get(valves, &1))
    |> Enum.map(&Map.get(&1, :flow_rate))
    |> Enum.reduce(current_pressure, &+/2)
  end

  def solve(input) do
    {:ok, path_process} = PathProcess.start_link({[], 0, 0})
    input
    |> step(path_process)
  end
end
