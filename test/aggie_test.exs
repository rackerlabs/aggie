require IEx

defmodule AggieTest do
  use ExUnit.Case
  doctest Aggie

  test "latest actions" do
    assert Aggie.Elk.latest_actions |> Enum.count > 0
    IO.inspect Aggie.Elk.latest_actions
  end

end
