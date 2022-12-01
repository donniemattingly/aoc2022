defmodule Day1Test do
  use ExUnit.Case, async: true

  test "part 1: ))((((( == 3" do
    assert Day1.parse_and_solve1("))(((((") == 3
  end

  test "part 1: (()(()( == 3" do
    assert Day1.parse_and_solve1("(()(()(") == 3
  end

  test "part 1 real" do
    assert Day1.part1() == 280
  end

  test "part 2: ) = 1" do
    assert Day1.parse_and_solve2(")") == 1
  end

  test "part 2 real" do
    assert Day1.part2() == 1797
  end
end
