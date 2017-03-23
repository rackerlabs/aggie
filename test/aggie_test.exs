require IEx

defmodule AggieTest do
  use ExUnit.Case
  doctest Aggie

  test "get_latest_request_ids" do
    assert Aggie.Elk.get_latest_request_ids |> Enum.count > 0
  end

  test "latest actions" do
    assert Aggie.Elk.latest_actions |> Enum.count > 1
  end

  test "we have data" do
    regex = ~r/darby/

    action = Enum.find(Aggie.Elk.latest_actions, fn(action) -> 
      Enum.any?(action, fn(str) -> Regex.match?(regex, str) end)
    end)

    assert action

  end

end
