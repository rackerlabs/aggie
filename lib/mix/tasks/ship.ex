defmodule Mix.Tasks.Ship do
  use Mix.Task

  @shortdoc "Ship the latest actions to Central Elk"
  def run(_) do
    Aggie.Elk.ship_latest_logs!() 
  end
end
