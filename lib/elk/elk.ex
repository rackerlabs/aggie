require IEx

defmodule Aggie.Elk do
  @moduledoc """
  Aggie is the RPC log aggregator
  """

  alias Aggie.Judge

  @ip "172.29.237.88:9200" # Darby

  @range "now-10m"
  @chunks 10000
  @timeout "1m"


  @doc """
  Aggregate OpenStack logs into cohesive actions via request ID
  """
  def latest_actions do
    Enum.reduce get_latest_request_ids(), [], fn(id, acc) ->
      acc ++ [get_info_about_request(id)]
    end
  end

  def get_info_about_request(id) do
    body = %{
      query: %{
        match: %{
	  logmessage: id
	}
      }
    } |> Poison.encode!

    case HTTPoison.request(:get, base_url(), body) do
      {:ok, resp} ->
        {:ok, json} = Poison.decode(resp.body)
        raw_logs    = json["hits"]["hits"]

        Enum.reduce raw_logs, [], fn(log, a) ->
          a ++ [log["_source"]["logmessage"]]
        end
    end
  end

  @doc """
  Loop through logs and get unique request IDs
  """
  def get_latest_request_ids do
    regex = ~r/(req-[a-z|0-9|-]*)/
    logs = valuable_logs()

    ids = Enum.reduce logs, [], fn(log, acc) ->
      message = log["_source"]["logmessage"]

      case message do
        nil -> message = log["_source"]["message"]
	_ -> message
      end

      matches = Regex.scan(regex, message)
      match   = matches |> Enum.uniq |> List.first

      case match do
        nil -> acc
        _ -> acc ++ match
      end
    end

    ids |> Enum.uniq
  end

  @doc """
  Forwards the latest valuable logs from local ELK to Central ELK
  """
  def ship_latest_logs! do
    Aggie.Shipper.ship!(valuable_logs())
  end



  def valuable_logs do
    Enum.reduce page([]), [], fn(log, acc) ->
      case Judge.verdict?(log) do
        true -> acc ++ [log]
        _    -> acc
      end
    end
  end

  defp page(acc) do
    case HTTPoison.request(:get, base_url(), page_request_body()) do
      {:ok, resp} ->
        {:ok, json} = Poison.decode(resp.body)
        raw_logs    = json["hits"]["hits"]

        case raw_logs do
          [] -> acc
          nil -> acc
          _  ->
            acc = acc ++ (raw_logs |> update_hostname)
            #page(acc, json["_scroll_id"])
            acc
        end
    end
  end

  defp page(acc, scroll_id) do
    url         = "#{base_url()}&scroll_id=#{scroll_id}"
    {:ok, resp} = HTTPoison.request(:get, url, page_request_body())
    {:ok, json} = Poison.decode(resp.body)
    raw_logs    = json["hits"]["hits"]

    case raw_logs do
      [] -> acc
      nil -> acc
      _  ->
          logs = raw_logs |> update_hostname
          page(acc ++ logs, json["_scroll_id"])
    end
  end

  defp base_url do
    {:ok, date} = Timex.format(Timex.today, "%Y.%m.%d", :strftime)
    name = "logstash-#{date}"
    "#{@ip}/#{name}/_search?scroll=#{@timeout}"
  end

  defp update_hostname(logs) do
    new_hostname = hostname(logs |> Enum.to_list |> List.first)

    Enum.map(logs, fn(l) ->
      put_in(l, ["_source", "beat", "hostname"], new_hostname)
    end)
  end

  defp hostname(log) do
    tenant_id = "930035"
    hostname  = log["_source"]["beat"]["hostname"]
    "#{tenant_id}.#{hostname}"
  end

  defp page_request_body do
    %{
      size: @chunks,
      sort: ["_doc"],
      query: %{
        bool: %{
          must: %{
            range: %{
              "@timestamp": %{
                gte: @range,
                lte: "now/d"
              }
            }
          }
        }
      }
    } |> Poison.encode!
  end
end
