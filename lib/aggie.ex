require IEx
require Aggie.Config

defmodule Aggie do
  alias Aggie.Config
  alias Aggie.Shipper

  @moduledoc """
  Aggie is the RPC log aggregator
  """

  @doc """
  Forwards the latest valuable logs from local ELK to Central ELK
  """
  def ship_logs do
    HTTPoison.start()
    Config.populate_app_config()
    Shipper.ship!(latest_logs())
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
    {:ok, date}    = Timex.format(Timex.today, "%Y.%m.%d", :strftime)
    name           = "logstash-#{date}"
    source_ip      = Application.get_env(:aggie, :source_ip)
    source_port    = Application.get_env(:aggie, :source_port)
    source_timeout = Application.get_env(:aggie, :source_timeout)

    "#{source_ip}:#{source_port}/#{name}/_search?scroll=#{source_timeout}"
  end



  defp page(acc) do
    req = HTTPoison.request(:get, base_url(), page_request_body())

    case req do
      {:error, _} -> IO.inspect(req)
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
    range  = Application.get_env(:aggie, :source_range)
    chunks = Application.get_env(:aggie, :source_chunks)

    "{
      size: \"#{chunks}\",
      sort: [\"_doc\"],
      query: {
        bool: {
          must_not: {
            terms: {
              tags: [\"libvirt\", \"apache\"]
            }
          },
          must: {
            range: {
              \"@timestamp\": {
                gte: \"#{range}\",
                lte: \"now/d\"
              }
            }
          }
        }
      }
    }"
  end
end
