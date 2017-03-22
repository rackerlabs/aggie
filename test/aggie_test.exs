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

  test "asdf" do
    regex = ~r/darby/
    action = Enum.find(Aggie.Elk.latest_actions, fn(a) -> Regex.match?(regex, a) end)
IO.inspect action
    # Enum.each(Aggie.Elk.latest_actions, fn(a) -> IO.puts a end)
  end

end
