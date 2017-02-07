require IEx

defmodule AggieTest do
  use ExUnit.Case
  doctest Aggie

  test "ping!" do
    assert Aggie.ping!.status_code == 200
  end

  test "raw_logs" do
    assert Aggie.raw_logs |> Enum.count > 1000
  end

  test "sifted_logs" do
    assert Aggie.sifted_logs |> Enum.count > 1000
  end
end
