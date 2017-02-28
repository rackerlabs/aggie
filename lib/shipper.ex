defmodule Aggie.Shipper do
  alias Aggie.Info

  @central_elk "162.242.253.228:9200"

  @doc """
  Forwards the latest valuable logs from local ELK to Central ELK
  """
  def ship!(data) do
    case is_map(data) do
      true  -> ship_elk_logs!(data)
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
    now   = Timex.now
    time  = now |> DateTime.to_iso8601
    date  = now |> Timex.format!("{YYYY}.{0M}.{D}")
    index = "rsyslog-#{date}"
    url   = "#{@central_elk}/#{index}/log"
    id    = Info.get(:app_data)[:tenant_id]
    data  = %{ message: log, "@timestamp": time, tenant_id: id }

    post!(url, data)
  end

  defp post!(url, body) do
    headers     = [{"Content-Type", "application/json"}]
    {:ok, json} = Poison.encode(body)

    case HTTPoison.post(url, json, headers) do
      {:ok, _} -> IO.puts(".")
      _ -> IO.puts("uh oh")
    end
  end

end
