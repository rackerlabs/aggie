require IEx

defmodule Aggie.Shipper do

  @central_elk "162.242.253.228:9200"

  @doc """
  Forwards the latest valuable logs from local ELK to Central ELK
  """
  def ship!(logs) do
    Enum.each(logs, fn(l) -> 
      post!(l["_source"] |> update_timestamp) 
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
    # Have: Thu Mar 23 14:28:10.614263 2017
    # Need: 2015/01/01 12:10:30

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
    "bouncing-ball8-#{date}"
  end

  defp post!(log) do
    # TODO: Clean up how tenant_id handling
    log         = log |> Map.merge(%{"tenant_id": "930035"})
    url         = "#{@central_elk}/#{index()}/log"
    headers     = [{"Content-Type", "application/json"}]
    {:ok, json} = Poison.encode(log)

IO.inspect log

    case HTTPoison.post(url, json, headers) do
      {:ok, _} -> IO.write '.'
      {:error, out} -> IO.inspect out
    end
  end

end
