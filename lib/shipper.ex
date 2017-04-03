require IEx

defmodule Aggie.Shipper do

  # @central_elk "10.184.6.65:9200"
  @central_elk "104.130.18.115:9200"

  @doc """
  Forwards the latest valuable logs from local ELK to Central ELK
  """
  def ship!(tenant_id, logs) do
    Enum.each(logs, fn(l) ->
      data = l["_source"]
        |> update_timestamp
        |> Map.merge(%{"tenant_id": tenant_id})

      post!(data)
    end)
  end

  defp update_timestamp(log) do
    timestamp = log["logdate"]

    case timestamp do
      nil -> log
      _ ->
        stamp = timestamp |> es_format()
        log
          |> Map.delete("@timestamp")
          |> Map.delete("logdate")
          |> Map.merge(%{"@timestamp": stamp})
    end
  end

  defp es_format(string) do
    try do
      {:ok, result} = Timex.parse(string, "%Y-%m-%d %H:%M:%S.%f", :strftime)
      {:ok, out} = Timex.format(result, "%Y/%m/%d %H:%M:%S", :strftime)
      out |> to_string()
    rescue
      # Many times the string will be blank.
      _ -> ""
    end
  end

  defp index do
    date = Timex.now |> Timex.format!("{YYYY}.{0M}.{D}")
    "aggie-#{date}"
  end

  defp post!(log) do
    url         = "#{@central_elk}/#{index()}/log"
    headers     = [{"Content-Type", "application/json"}]
    {:ok, json} = Poison.encode(log)

    case HTTPoison.post(url, json, headers) do
      {:ok, _} -> IO.write '.'
      {:error, out} -> IO.inspect out
    end
  end

end
