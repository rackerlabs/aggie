require IEx

defmodule AggieTest do
  use ExUnit.Case
  doctest Aggie

  test "latest actions" do
    assert Aggie.Elk.Action.latest_actions |> Enum.count > 1
  end

  test "we have data" do
    regex = ~r/darby/

    action = Enum.find(Aggie.Elk.latest_actions, fn(action) ->
      Enum.any?(action, fn(str) -> Regex.match?(regex, str) end)
    end)

    assert action
  end

  test "payload" do
    {:ok, body} = File.read("test/sample_action.txt")
    {:ok, json} = Poison.decode(body)
    out = Aggie.Elk.Action.parse_action(json)
    assert out.uuid
    assert out.project_id
    assert out.domain_id
    assert out.request_id
    assert out.image_name
    assert out.image_id
  end

end
