require IEx

defmodule AggieTest do
  use ExUnit.Case
  doctest Aggie

  test "ping!" do
    assert Aggie.ping!.status_code == 200
  end

  test "logs" do
    raw = Aggie.raw_logs |> Enum.count
    sifted = Aggie.sifted_logs |> Enum.count
    assert raw == sifted # TODO :)
  end
end
