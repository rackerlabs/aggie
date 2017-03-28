require IEx

defmodule Aggie.Shipper do

  @central_elk "162.242.253.228:9200"

  @doc """
  Forwards the latest valuable logs from local ELK to Central ELK
  """
  def ship!(logs) do
    Enum.each(logs, fn(l) -> post!(l) end)
  end

  defp index do
    date = Timex.now |> Timex.format!("{YYYY}.{0M}.{D}")
    "aggie4-#{date}"
  end

  defp post!(log) do
    url         = "#{@central_elk}/#{index()}/log"
    headers     = [{"Content-Type", "application/json"}]
    {:ok, json} = Poison.encode(log)
    here = HTTPoison.post(url, json, headers)
IO.inspect here
here
  end

end
