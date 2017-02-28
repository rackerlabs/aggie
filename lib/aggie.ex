defmodule Aggie do

  alias Aggie.Info
  alias Aggie.SyslogServer

  def start_syslog_server(opts) do
    store_tenant_id(opts)
    SyslogServer.listen(7777)
  end

  defp store_tenant_id(opts) do
    tenant_id = Keyword.get(opts, :tenant_id)
    Info.start_link(:app_data)
    Info.push(:app_data, %{ tenant_id: tenant_id })
  end

end
