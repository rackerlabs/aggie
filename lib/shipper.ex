require IEx

defmodule Aggie.Shipper do

  @central_elk "162.242.253.228:9200"

  @doc """
  Forwards the latest valuable logs from local ELK to Central ELK
  """
  def ship!(logs) do
    Enum.each(logs, fn(l) -> post!(l["_source"]) end)
  end

  defp index do
    date = Timex.now |> Timex.format!("{YYYY}.{0M}.{D}")
    "bouncing-ball5-#{date}"
  end

  defp post!(log) do
    # TODO: Clean up how tenant_id handling
    log         = log |> Map.merge(%{tenant_id: "930035"})
    url         = "#{@central_elk}/#{index()}/log"
    headers     = [{"Content-Type", "application/json"}]
    {:ok, json} = Poison.encode(log)

    case HTTPoison.post(url, json, headers) do
      {:ok, _} -> IO.write '.'
      {:error, out} -> IO.inspect out
    end
  end

end
