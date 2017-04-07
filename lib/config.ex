require IEx

defmodule Aggie.Config do

  @moduledoc """
  Aggie.Config pulls env variables for app configuration during runtime.
  """

  @doc """
  Goes through aggie environment variables and populates the application config
  """
  def populate_app_config() do

    # Get env variables on runtime and activate
    source_ip = System.get_env("AGGIE_SOURCE_IP")
    Application.put_env(:aggie, :source_ip, source_ip)

    source_port = System.get_env("AGGIE_SOURCE_PORT")
    Application.put_env(:aggie, :source_port, source_port)

    source_timeout = System.get_env("AGGIE_SOURCE_TIMEOUT")
    Application.put_env(:aggie, :source_timeout, source_timeout)

    source_range = System.get_env("AGGIE_SOURCE_RANGE")
    Application.put_env(:aggie, :source_range, source_range)

    source_chunks = System.get_env("AGGIE_SOURCE_CHUNKS")
    Application.put_env(:aggie, :source_chunks, source_chunks)

    destination_ip = System.get_env("AGGIE_DESTINATION_IP")
    Application.put_env(:aggie, :destination_ip, destination_ip)

    destination_port = System.get_env("AGGIE_DESTINATION_PORT")
    Application.put_env(:aggie, :destination_port, destination_port)

  end

end
