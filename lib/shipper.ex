defmodule Aggie.Shipper do

  @central_elk "162.242.253.228:9200"

  @doc """
  Forwards the latest valuable logs from local ELK to Central ELK
  """
  def ship!(data) do
    case is_map(data) do
      true -> ship_elk_logs!(data)
      false -> ship_syslog_log!(data)
    end
  end



  defp ship_elk_logs!(logs) do
    Enum.each(logs, fn(l) ->
      {:ok, body} = Poison.encode(l["_source"])
      url         = "#{@central_elk}/#{l["_index"]}/log"

      post!(url, body)
    end)
  end

  defp ship_syslog_log!(log) do
    {:ok, body} = Poison.encode(log)
    date        = Timex.format!(Timex.now, "{YYYY}.{0M}.{D}")
    index       = "syslog-#{date}"
    url         = "#{@central_elk}/#{index}/log"

    post!(url, body)
  end

  defp post!(url, body) do
    headers = [{"Content-Type", "application/json"}]
    
    IO.puts url

    case HTTPoison.post(url, body, headers) do
      {:ok, _} -> IO.puts(".")
      _ -> IO.puts("uh oh")
    end
  end

end
