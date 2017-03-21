require IEx

defmodule Aggie.Elk do
  @moduledoc """
  Aggie is the RPC log aggregator
  """

  alias Aggie.Judge

  @ip "172.29.238.40:9200" # Darby
  # @ip "172.29.238.99:9200" # Antony

  @range "now-120m"
  @chunks 1000
  @timeout "1m"

  @doc """
  Aggregate OpenStack logs into cohesive actions via request ID
  """
  def latest_actions do
    Enum.reduce get_latest_request_ids(), [], fn(id, acc) ->
      acc ++ get_info_about_request(id)
    end
  end

  def get_info_about_request(id) do
    url = "#{base_url()}&q=#{id}"

    case HTTPoison.request(:get, url) do
      {:ok, resp} ->
        {:ok, json} = Poison.decode(resp.body)
        raw_logs    = json["hits"]["hits"]

        Enum.reduce raw_logs, [], fn(log, a) ->
          a ++ [log["_source"]["message"]]
        end
    end
  end

  @doc """
  Loop through logs and get unique request IDs
  """
  def get_latest_request_ids do
    regex = ~r/req-[a-z|0-9|-]*/

    ids = Enum.reduce valuable_logs(), [], fn(log, acc) ->
      message = log["_source"]["message"]
      match   = Regex.scan(regex, message) |> List.first

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



  defp valuable_logs do
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
          [] -> []
          nil -> []
          _  ->
            acc = acc ++ (raw_logs |> update_hostname)
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
        count = raw_logs |> Enum.count

        # For some reason in ES 2.4.1 we receive
        # the last ten results repeatedly. Let's
        # use that as a stop condition.
        case count do
          10 -> acc
          _ ->
            logs = raw_logs |> update_hostname
            page(acc ++ logs, json["_scroll_id"])
        end
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
