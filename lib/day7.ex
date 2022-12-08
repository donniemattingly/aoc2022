defmodule Day7 do
  use Utils.DayBoilerplate, day: 7
  use Memoize

  def sample_input do
    """
    $ cd /
    $ ls
    dir a
    14848514 b.txt
    8504156 c.dat
    dir d
    $ cd a
    $ ls
    dir e
    29116 f
    2557 g
    62596 h.lst
    $ cd e
    $ ls
    584 i
    $ cd ..
    $ cd ..
    $ cd d
    $ ls
    4060174 j
    8033020 d.log
    5626152 d.ext
    7214296 k
    """
  end

  def parse_input(input) do
    input
    |> Utils.split_lines()
    |> Enum.map(&parse_line/1)
  end

  def parse_line("$ cd .."), do: {:cd, :up}
  def parse_line("$ cd " <> dir), do: {:cd, dir}
  def parse_line("$ ls"), do: {:ls}
  def parse_line("dir " <> dir), do: {:dir, dir}

  def parse_line(line) do
    [[_, size, name]] = Regex.scan(~r/(\d+) ([\w|\.]+)/, line)
    {:file, {String.to_integer(size), String.trim(name)}}
  end

  def get_dir_sizes(input) do
    input
    |> Enum.reduce({%{}, []}, fn x, {sizes, path} ->

      case x do
        {:ls} ->
          {sizes, path}

        {:dir, dir} ->
          {sizes, path}

        {:cd, :up} ->
          {sizes, Enum.drop(path, -1)}

        {:cd, dir} ->
          {sizes, path ++ [dir]}

        {:file, {size, _}} ->
          Enum.reduce(path, {sizes, []}, fn dir, {s, p} ->
            new_path = p ++ [dir]
            {Map.update(s, new_path, size, &(&1 + size)), new_path}
          end)

        x ->
          {sizes, path}
      end
    end)
    |> elem(0)
  end

  def solve(input) do
    input
    |> get_dir_sizes()
    |> Map.to_list()
    |> Enum.filter(fn {_, size} -> size < 100_000 end)
    |> Enum.map(& elem(&1, 1))
    |> Enum.sum()
  end

  def solve2(input) do
    sizes = input |> get_dir_sizes()
    used = Map.get(sizes, ["/"])
    free = 70000000 - used
    need = 30000000 - free

    Enum.min_by(
      Enum.filter(sizes, fn {path, size} -> size > need end),
      fn {path, size} -> size end
    )
  end
end
