require IEx

defmodule AggieTest do
  use ExUnit.Case
  doctest Aggie

  test "latest actions" do
    assert Aggie.Elk.latest_actions |> Enum.count > 0
    IO.inspect Aggie.Elk.latest_actions
    IO.inspect Aggie.Elk.get_latest_request_ids()
  end

end
