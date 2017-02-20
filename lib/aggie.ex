require IEx

defmodule Aggie do
  @moduledoc """
  Aggie is the RPC log aggregator
  """

  @ip "146.20.110.235:9200"
  @range "now-15m"
  @chunks 100
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


  defp page(acc) do
    url         = "#{@ip}/_search?scroll=#{@timeout}"
    {:ok, resp} = HTTPoison.request(:get, url, request_body())
    {:ok, json} = Poison.decode(resp.body)

    acc = acc ++ json["hits"]["hits"]

    page(acc, json["_scroll_id"])
  end

  defp page(acc, scroll_id) do
    url         = "#{@ip}/_search/scroll?scroll=#{@timeout}&scroll_id=#{scroll_id}"
    resp        = HTTPoison.get!(url)
    {:ok, json} = Poison.decode(resp.body)
    logs        = json["hits"]["hits"]

    case logs do
      [] -> acc
      _  -> page(acc ++ logs, json["_scroll_id"])
    end
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
