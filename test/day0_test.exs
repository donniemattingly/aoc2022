defmodule Day0Test do
  use ExUnit.Case, async: true

  test "part 1" do
    assert Day0.parse_and_solve1('test') == 'test'
  end
end
