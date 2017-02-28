defmodule Commandline.CLI do

  def main(args) do
    {opts,_,_} = OptionParser.parse(args, switches: [syslog: :boolean, tenant_id: :string])

    case valid_syslog_setup?(opts) do
      true  -> Aggie.start_syslog_server(opts)
      false -> Aggie.Elk.ship!
    end
  end

  defp valid_syslog_setup?(opts) do
    Keyword.has_key?(opts, :syslog) && Keyword.has_key?(opts, :tenant_id)
  end

end
