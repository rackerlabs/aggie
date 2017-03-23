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

  test "getting the UUID" do
    {:ok, body} = File.read("test/sample_action.txt")
    {:ok, json} = Poison.decode(body)

    uuid       = ~r/, id:\s([a-z|0-9|-]*), size:/
    project_id = ~r/projects\/([a-z|0-9]*)/
    domain_id  = ~r/domain_id\\": \\"(\w+)\\"/
    request_id = ~r/\[(req[a-z|0-9|-]*)/
    image_name = ~r/image_name:\s(.*), image_id:/
    image_id   = ~r/image_id:\s(.*), container/

#     -   Duration
#     -   Assigned Host
#     -   Error message
#     -   Flavor and specs and tags
#     -   Network Ports Information (see below)
#     -   Attached volumes

    IO.inspect json
  end

end
