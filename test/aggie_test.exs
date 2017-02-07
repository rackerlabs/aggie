require IEx

defmodule AggieTest do
  use ExUnit.Case
  doctest Aggie

  test "ping!" do
    assert Aggie.ping!.status_code == 200
  end

  test "pages" do
    out = Aggie.page
    assert out[:scroll_id] != ""
    assert out[:logs] |> Enum.count == 50
  end

  test "scrolling" do
    first = Aggie.page
    second = Aggie.page(first[:scroll_id])
    assert first[:logs] != second[:logs]
  end

  test "hydration" do
    assert Enum.count(Aggie.page[:logs]) == 50
  end
end
