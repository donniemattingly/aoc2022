defmodule Day3Test do
  use ExUnit.Case, async: true

  test "part 1: ^v^v^v^v^v" do
    assert Day3.parse_and_solve1("^v^v^v^v^v") == 2
  end

  test "part 1: ^>v<" do
    assert Day3.parse_and_solve1("^>v<") == 4
  end

  test "part 1: real" do
    assert Day3.part1() == 2081
  end

  test "part 2: ^v^v^v^v^v" do
    assert Day3.parse_and_solve2("^v^v^v^v^v") == 11
  end

  test "part 2: ^>v<" do
    assert Day3.parse_and_solve2("^>v<") == 3
  end

  test "part 2: real" do
    assert Day3.part2() == 2341
  end
end
