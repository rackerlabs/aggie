defmodule Aggie.Elk.Action do

  @doc """
  Aggregate OpenStack logs into cohesive actions via request ID
  """
  def latest_actions do
    Enum.reduce get_latest_request_ids(), [], fn(id, acc) ->
      acc ++ [get_info_about_request(id)]
    end
  end

  def get_info_about_request(id) do
    body = %{
      query: %{
        match: %{
      	  logmessage: id
      	}
      }
    } |> Poison.encode!

    case HTTPoison.request(:get, Aggie.Elk.base_url(), body) do
      {:ok, resp} ->
        {:ok, json} = Poison.decode(resp.body)
        raw_logs    = json["hits"]["hits"]

        Enum.reduce raw_logs, [], fn(log, a) ->
          a ++ [log["_source"]["logmessage"]]
        end
    end
  end

  @doc """
  Loop through logs and get unique request IDs
  """
  def get_latest_request_ids do
    regex = ~r/(req-[a-z|0-9|-]*)/
    logs = Aggie.Elk.latest_logs()

    ids = Enum.reduce logs, [], fn(log, acc) ->
      message = log["_source"]["logmessage"]

      message = case message do
        nil -> log["_source"]["message"]
      	_ -> message
      end

      matches = Regex.scan(regex, message)
      match   = matches |> Enum.uniq |> List.first

      case match do
        nil -> acc
        _ -> acc ++ match
      end
    end

    ids |> Enum.uniq
  end
end
