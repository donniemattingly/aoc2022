defmodule AutoReload do
  use GenServer

  def watch() do
    start_link(dirs: [File.cwd!()])
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(args)
    {:ok, pid} = Debounce.start_link({IEx.Helpers, :recompile, []}, 100)
    FileSystem.subscribe(watcher_pid)
    {:ok, %{watcher_pid: watcher_pid, debounce_pid: pid}}
  end

  def handle_info(
        {:file_event, watcher_pid, {path, events}},
        %{watcher_pid: watcher_pid, debounce_pid: pid} = state
      ) do
    # Your own logic for path and events
    Debounce.apply(pid)
    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    # Your own logic when monitor stop
    IO.puts("stopped")
    {:noreply, state}
  end
end
