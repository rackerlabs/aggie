defmodule Commandline.CLI do
  def main(args) do
    {opts,_,_} = OptionParser.parse(args, switches: [syslog: :boolean])

    case Keyword.has_key?(opts, :syslog) do
      true  -> Aggie.SyslogServer.listen(7777)
      false -> Aggie.Elk.ship!
    end
  end
end
