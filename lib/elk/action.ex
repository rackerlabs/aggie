require IEx

defmodule Aggie.Elk.Action do

  # MISSING:
  # Duration
  # Assigned Host
  # Error message
  # Flavor and specs and tags
  # Network Ports Information (see below)
  # Attached volumes

  @uuid_regex        ~r/, id:\s([a-z|0-9|-]*), size:/
  @project_id_regex  ~r/projects\/([a-z|0-9]*)/
  @domain_id_regex   ~r/domain_id\": \"(\w+)\"/
  @request_id_regex  ~r/\[(req[a-z|0-9|-]*)/
  @image_name_regex  ~r/image_name:\s(.*), image_id:/
  @image_id_regex    ~r/image_id:\s(.*), container/
  @timestamp_regex   ~r/\[(\w{3}\s\w{3}\s\d{2}\s\d{2}:\d{2}:\d{2}.\d+\s\d{4})\]/


  @doc """
  Aggregate OpenStack logs into cohesive actions via request ID
  """
  def latest_actions do
    Enum.reduce get_latest_request_ids(), [], fn(id, acc) ->
      acc ++ [(get_info_about_request(id) |> parse_action)]
      # acc ++ [get_info_about_request(id)]
    end
  end

  def parse_action(action) do
    string = action |> Enum.join(" ")

    uuid = try do
      Regex.run(@uuid_regex, string) |> List.last
    rescue
      FunctionClauseError -> ""
    end

    timestamp = try do
      Regex.run(@timestamp_regex, string) |> List.last
    rescue
      FunctionClauseError -> ""
    end

    project_id = try do
      Regex.run(@project_id_regex, string) |> List.last
    rescue
      FunctionClauseError -> ""
    end

    domain_id = try do
      Regex.run(@domain_id_regex, string) |> List.last
    rescue
      FunctionClauseError -> ""
    end

    request_id = try do
      Regex.run(@request_id_regex, string) |> List.last
    rescue
      FunctionClauseError -> ""
    end

    image_name = try do
      Regex.run(@image_name_regex, string) |> List.last
    rescue
      FunctionClauseError -> ""
    end

    image_id = try do
      Regex.run(@image_id_regex, string) |> List.last
    rescue
      FunctionClauseError -> ""
    end

    %{
      uuid: uuid,
      project_id: project_id,
      domain_id: domain_id,
      request_id: request_id,
      image_name: image_name,
      image_id: image_id,
      timestamp: timestamp
    }
  end


  defp get_info_about_request(id) do
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

  defp get_latest_request_ids do
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
