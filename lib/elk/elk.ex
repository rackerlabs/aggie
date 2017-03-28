require IEx

defmodule Aggie.Elk do
  @moduledoc """
  Aggie is the RPC log aggregator
  """

  @ip "172.29.237.88:9200" # Darby

  @range "now-10m"
  @chunks 10000
  @timeout "1m"

  @doc """
  Group recent Openstack requests into "actions"
  """
  def latest_actions do
    Aggie.Elk.Action.latest_actions()
  end

  @doc """
  Forwards the latest valuable logs from local ELK to Central ELK
  """
  def ship_latest_logs! do
    Aggie.Shipper.ship!(latest_actions())
  end

  @doc """
  Get the latest logs from the local Elasticsearch container
  """
  def latest_logs do
    Enum.reduce(page([]), [], fn(log, acc) -> acc ++ [log] end)
  end

  @doc """
  The base Elasticsearch URL
  """
  def base_url do
    {:ok, date} = Timex.format(Timex.today, "%Y.%m.%d", :strftime)
    name = "logstash-#{date}"
    "#{@ip}/#{name}/_search?scroll=#{@timeout}"
  end



  defp page(acc) do
    case HTTPoison.request(:get, base_url(), page_request_body()) do
      {:ok, resp} ->
        {:ok, json} = Poison.decode(resp.body)
        raw_logs    = json["hits"]["hits"]

        case raw_logs do
          [] -> acc
          nil -> acc
          _  -> acc ++ raw_logs
        end
    end
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
