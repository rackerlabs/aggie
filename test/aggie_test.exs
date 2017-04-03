require IEx

defmodule AggieTest do
  use ExUnit.Case

  test "latest actions" do
    assert Aggie.latest_logs() |> Enum.count > 1
  end
end
