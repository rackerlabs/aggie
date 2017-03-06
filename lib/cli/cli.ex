defmodule Aggie.CLI do

  def main(args) do
    {opts,_,_} = OptionParser.parse(args, switches: [syslog: :boolean, tenant_id: :string])

    cond do
      valid_syslog_setup?(opts) -> Aggie.start_syslog_server(opts)
      valid_elk_setup?(opts) -> Aggie.Elk.ship_latest_logs!
      true -> print_usage()
    end
  end

  defp valid_syslog_setup?(opts) do
    Keyword.has_key?(opts, :syslog) && Keyword.has_key?(opts, :tenant_id)
  end

  defp valid_elk_setup?(opts) do
    Keyword.has_key?(opts, :tenant_id)
  end

  defp print_usage do
    IO.puts "Error: Requires --tenant-id"
  end

end
