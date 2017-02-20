require IEx

defmodule Aggie.Logs.CinderTest do
  use ExUnit.Case
  doctest Aggie

  alias Aggie.Logs.Cinder

  @valid_log %{"_id" => "AVoebpcoAGbYccPXMO0I", "_index" => "logstash-2017.02.08", "_score" => 1.0, "_source" => %{"@timestamp" => "2017-02-08T15:54:06.715Z", "@version" => "1", "beat" => %{"hostname" => "rpc-openstack", "name" => "rpc-openstack"}, "count" => 1, "host" => "rpc-openstack", "input_type" => "log", "message" => "", "offset" => 1519774, "source" => "/var/log/cinder/cinder-api.log", "tags" => ["openstack", "oslofmt", "cinder"], "type" => "log"}, "_type" => "log"}

  test "is_cinder?" do
    assert Cinder.is_cinder?(@valid_log) == true
  end
end
