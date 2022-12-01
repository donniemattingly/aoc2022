defmodule Day6Test do
  use ExUnit.Case, async: true

  test "part 1: real" do
    assert Day6.part1() == 543_903
  end

  test "part 2: real" do
    assert Day6.part2() == 14_687_245
  end
end
