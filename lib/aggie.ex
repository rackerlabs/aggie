require IEx

defmodule Aggie do
  @moduledoc """
  Aggie is the RPC log aggregator
  """

  alias Aggie.Judge

  @ip "172.29.238.40:9200"
  @central_elk "162.242.253.228:9200"

  @primary_config "/etc/openstack_deploy/user_rpco_variables_overrides.yml"
  @secondary_config "/etc/rpc_deploy/user_variables.yml"
  @tertiary_config File.cwd! |> Path.join("test/sample.yml")

  @range "now-10days"
  @chunks 1000
  @timeout "1m"

  @doc """
  Forwards the latest valuable logs from local ELK to Central ELK
  """
  def ship! do
    logs  = logs()
    count = logs |> Enum.count

    IO.puts "Found #{count} valuable logs"

    Enum.each(logs, fn(l) ->
      {:ok, body} = Poison.encode(l["_source"])
      headers     = [{"Content-Type", "application/json"}]
      url         = "#{@central_elk}/#{l["_index"]}/log"

      case HTTPoison.post(url, body, headers) do
        {:ok, _} -> IO.puts(".")
        _ -> IO.puts("uh oh")
      end
    end)
  end



  defp logs do
    Enum.reduce page([]), [], fn(log, acc) ->
      case Judge.verdict?(log) do
        true -> acc ++ [log]
        _    -> acc
      end
    end
  end

  defp page(acc) do
    case HTTPoison.request(:get, base_url(), page_request_body()) do
      {:error, resp} -> IO.inspect(resp)
      {:ok, resp} ->
        {:ok, json} = Poison.decode(resp.body)
        raw_logs    = json["hits"]["hits"]

        case raw_logs do
          [] -> []
          nil -> []
          _  ->
            count = raw_logs |> Enum.count
            IO.puts "Found #{count} raw logs"

            acc = acc ++ update_hostname(raw_logs)
            page(acc, json["_scroll_id"])
        end
    end
  end

  defp page(acc, scroll_id) do
    url         = "#{base_url()}&scroll_id=#{scroll_id}"
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

  defp base_url do
    {:ok, date} = Timex.format(Timex.today, "%Y.%m.%d", :strftime)
    name = "logstash-#{date}"
    
    IO.puts name

    "#{@ip}/#{name}/_search?scroll=#{@timeout}"
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

  defp tenant_id do
    path = cond do
      File.exists?(@primary_config) -> @primary_config
      File.exists?(@secondary_config) -> @secondary_config
      File.exists?(@tertiary_config) -> @tertiary_config
      true -> raise "No config file for MaaS?"
    end

    config = YamlElixir.read_from_file(path)
    config["maas_tenant_id"]
  end

  defp page_request_body do
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
