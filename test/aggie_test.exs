require IEx

defmodule AggieTest do
  use ExUnit.Case
  doctest Aggie

  test "ping!" do
    assert Aggie.ping!.status_code == 200
  end

  test "logs" do
    assert Aggie.logs |> Enum.count > 0
  end
end
