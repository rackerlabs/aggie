require IEx

defmodule Aggie do
  @moduledoc """
  Aggie is the RPC log aggregator
  """

  @ip "146.20.110.235:9200"
  # @ip "0.0.0.0:9200"
  @primary_config "/etc/openstack_deploy/user_rpco_variables_overrides.yml"
  @secondary_config "/etc/rpc_deploy/user_variables.yml"
  @tertiary_config File.cwd! |> Path.join("test/sample.yml")

  @range "now-10m"
  @chunks 1000
  @timeout "1m"

  alias Aggie.Judge

  @doc """
  Ping the Elasticsearch server
  """
  def ping! do
    HTTPoison.get!(@ip)
  end

  @doc """
  Grabs the latest valuable logs from ElasticSearch
  """
  def logs do
    Enum.reduce page([]), [], fn(log, acc) ->
      case Judge.verdict?(log) do
        true -> acc ++ [log]
        _    -> acc
      end
    end
  end

  def tenant_id do
    path = cond do
      File.exists?(@primary_config) -> @primary_config
      File.exists?(@secondary_config) -> @secondary_config
      File.exists?(@tertiary_config) -> @tertiary_config
      true -> "raise some error"
    end

    config = YamlElixir.read_from_file(path)
    config["maas_tenant_id"]
  end


  defp page(acc) do
    url         = "#{@ip}/_search?scroll=#{@timeout}"
    {:ok, resp} = HTTPoison.request(:get, url, request_body())
    {:ok, json} = Poison.decode(resp.body)
    raw_logs    = json["hits"]["hits"]

    case raw_logs do
      [] -> []
      nil -> []
      _  ->
        acc = acc ++ update_hostname(raw_logs)
        page(acc, json["_scroll_id"])
    end
  end

  defp page(acc, scroll_id) do
    url         = "#{@ip}/_search/scroll?scroll=#{@timeout}&scroll_id=#{scroll_id}"
    resp        = HTTPoison.get!(url)
    {:ok, json} = Poison.decode(resp.body)
    raw_logs    = json["hits"]["hits"]

    case raw_logs do
      [] -> acc
      nil -> acc
      _  ->
        logs = update_hostname(raw_logs)
        page(acc ++ logs, json["_scroll_id"])
    end
  end

  defp update_hostname(logs) do
    new_hostname = hostname(logs |> Enum.to_list |> List.first)

    Enum.map(logs, fn(l) ->
      put_in(l, ["_source", "beat", "hostname"], new_hostname)
    end)
  end

  defp hostname(log) do
    tenant_id = tenant_id()
    hostname  = log["_source"]["beat"]["hostname"]
    "#{tenant_id}.#{hostname}"
  end

  defp request_body do
    %{
      size: @chunks,
      query: %{
        bool: %{
          must_not: [
            %{term: %{ "loglevel": "debug" } },
            %{term: %{ "loglevel": "info" } }
          ],
          must: %{
            range: %{
              "@timestamp": %{
                gte: @range
              }
            }
          }
        }
      }
    }
    |> Poison.encode!
  end
end
