Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"NiwyQDR~tMSJ~wDuibRKZIG9]W>eVQr`f1!I]x.Zq:xIKw:1tXy,%8:w/;>Wq2CW"
end

environment :prod do
  set include_src: false
  set include_erts: "ubuntu_erts"
  set cookie: :"Ltz/hf`Q~usQ??>h8&yts&=yl6LON8]{iGa4p6t!R:/![}A$4bdKOzRd.B^R6:X%"
end

release :aggie do
  set version: "0.1.0"
  set commands: [
    "ship": "rel/commands/ship.sh"
  ]
  set applications: [
    elk: :permanent,
    judge: :permanent,
    shipper: :permanent,
    syslog: :permanent
  ]
end
