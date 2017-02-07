require IEx

defmodule Aggie do
  @ip "146.20.110.235:9200"
  @range "now-1m"
  @chunks 1000
  @timeout "1m"

  alias Aggie.Sifter

  @moduledoc """
  Aggie is the RPC log aggregator
  """

  @doc """
  Ping the Elasticsearch server
  """
  def ping! do
    HTTPoison.get!(@ip)
  end

  @doc """
  Sift through the logs for valuable info
  """
  def sifted_logs do
    raw_logs() |> Sifter.sift!([])
  end

  @doc """
  Grab the latest logs from ElasticSearch
  """
  def raw_logs do
    page([])
  end


  defp page(acc) do
    url  = "#{@ip}/_search?scroll=#{@timeout}"
    body = %{size: @chunks, query: %{range: %{"@timestamp": %{gt: @range}}}}
            |> Poison.encode!

    {:ok, resp} = HTTPoison.request(:get, url, body)
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
end
