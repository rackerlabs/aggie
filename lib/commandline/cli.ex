defmodule Commandline.CLI do
  def main(args) do
    # {opts,_,_} = OptionParser.parse(args, switches: [file: :string],aliases: [f: :file])
    IO.puts Aggie.logs |> Enum.count
  end
end
