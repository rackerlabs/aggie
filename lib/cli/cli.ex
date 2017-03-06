defmodule Aggie.CLI do

  @version 0.1

  def main(args) do
    {opts,_,_} = OptionParser.parse(args, switches:
      [
        syslog: :boolean,
        tenant_id: :string,
        version: :boolean
      ]
    )

    cond do
      valid_syslog_setup?(opts) -> Aggie.start_syslog_server(opts)
      valid_elk_setup?(opts) -> Aggie.Elk.ship_latest_logs!
      asking_for_version?(opts) -> print_version()
      true -> print_usage()
    end
  end

  defp valid_syslog_setup?(opts) do
    Keyword.has_key?(opts, :syslog) && Keyword.has_key?(opts, :tenant_id)
  end

  defp valid_elk_setup?(opts) do
    Keyword.has_key?(opts, :tenant_id)
  end

  defp asking_for_version?(opts) do
    Keyword.has_key?(opts, :version)
  end

  defp print_usage do
    IO.puts "Error: Requires --tenant-id"
  end

  defp print_version do
    IO.puts "Aggie v#{@version}"
  end

end
