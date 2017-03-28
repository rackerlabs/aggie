defmodule ShipLogsBench do
  use Benchfella

  bench "ship logs" do
    Aggie.Elk.ship_latest_logs!
  end
end
