defmodule Utils.DayBoilerplate do
  defmacro __using__(options) do
    quote do
      def real_input do
        AdventOfCode.download_input(2022, unquote(Keyword.get(options, :day)))
      end

      def sample_input do
        """
        """
      end

      def sample_input2 do
        sample_input()
      end

      def sample do
        sample_input()
        |> parse_input1
        |> solve1
      end

      def part1 do
        real_input1()
        |> parse_input1
        |> solve1
      end

      def sample2 do
        sample_input2()
        |> parse_input2
        |> solve2
      end

      def part2 do
        real_input2()
        |> parse_input2
        |> solve2
      end

      def real_input1, do: real_input()
      def real_input2, do: real_input()

      def parse_input1(input), do: parse_input(input)
      def parse_input2(input), do: parse_input(input)

      def solve1(input), do: solve(input)
      def solve2(input), do: solve(input)

      def parse_and_solve1(input),
        do:
          parse_input1(input)
          |> solve1

      def parse_and_solve2(input),
        do:
          parse_input2(input)
          |> solve2

      def parse_input(input) do
        input
      end

      def solve(input) do
        input
      end

      defoverridable solve: 1, solve1: 1, solve2: 1, parse_input: 1, sample_input: 0
    end
  end
end
