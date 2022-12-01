defmodule Day5Test do
  use ExUnit.Case, async: true

  test "ugknbfddgicrmopn is nice" do
    assert Day5.is_nice("ugknbfddgicrmopn") == true
  end

  test "aaa is nice" do
    assert Day5.is_nice("aaa") == true
  end

  test "jchzalrnumimnmhp is naughty" do
    assert Day5.is_nice("jchzalrnumimnmhp") == false
  end

  test "haegwjzuvuyypxyu is naughty" do
    assert Day5.is_nice("haegwjzuvuyypxyu") == false
  end

  test "dvszwmarrgswjxmb is naughty" do
    assert Day5.is_nice("dvszwmarrgswjxmb") == false
  end

  test "part 1: real" do
    assert Day5.part1() == 258
  end

  test "part 2: real" do
    assert Day5.part2() == 53
  end
end
