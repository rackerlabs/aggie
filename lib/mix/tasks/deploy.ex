defmodule Mix.Tasks.Deploy do
  use Mix.Task

  @shortdoc "Deploy the app to production"
  def run(_) do
    System.cmd("mix", ["release"], env: [{"MIX_ENV", "prod"}])
    System.cmd("scp", ["_build/prod/rel/aggie/releases/0.1.0/aggie.tar.gz", "root@162.242.211.60:~/"])
  end
end
