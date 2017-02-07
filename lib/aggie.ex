require IEx

defmodule Aggie do
  @ip "146.20.110.235:9200"
  @range "now-15m"
  @chunks 50
  @timeout "1m"

  alias Aggie.Sifter

  @moduledoc """
  Documentation for Aggie.
  """

  @doc """
  Ping the Elasticsearch server
  """
  def ping! do
    HTTPoison.get!(@ip)
  end

  @doc """
  Grab the latest logs from ElasticSearch
  """
  def latest_logs do
    #TODO:  We must loop over this until hits == []
  end

  def page(scroll_id \\ nil) do
    #TODO:  Wrap this in streams

    base_url = "#{@ip}/_search?scroll=#{@timeout}"

    url = case scroll_id do
      nil -> base_url
      _   -> "#{base_url}&scroll_id=#{scroll_id}"
    end

    body        = %{size: @chunks, query: %{range: %{"@timestamp": %{gt: @range}}}}
    {:ok, resp} = HTTPoison.request(:get, url, body |> Poison.encode!)
    {:ok, json} = Poison.decode(resp.body)
    scroll_id   = json["_scroll_id"]
    logs        = json["hits"]["hits"] |> Sifter.sift!([])

    %{scroll_id: scroll_id, logs: logs}
  end

end
