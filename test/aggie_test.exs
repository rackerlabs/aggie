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

  test "tenant_id" do
    assert Aggie.tenant_id() == 930035
  end

  test "updating the hostname" do
    log = Aggie.logs |> Enum.to_list |> List.first
    assert log["_source"]["beat"]["hostname"] == "930035.rpc-openstack"
  end
end
