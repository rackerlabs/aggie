defmodule Aggie.Judge do
  alias Aggie.Logs.Cinder
  # alias Aggie.Logs.Glance
  # alias Aggie.Logs.Keystone
  # alias Aggie.Logs.Neutron
  # alias Aggie.Logs.Nova

  @doc """
  Let the Judge decide if an ELK log is interesting
  """
  def verdict?(elk_log) do
    service_judge(elk_log)
  end


  defp service_judge(elk_log) do
    cond do
      Cinder.is_cinder?(elk_log) -> Cinder.judge!(elk_log)
      # Glance.is_glance?(elk_log) -> Glance.judge!(elk_log)
      # Keystone.is_keystone?(elk_log) -> Keystone.judge!(elk_log)
      # Neutron.is_neutron?(elk_log) -> Neutron.judge!(elk_log)
      # Nova.is_nova?(elk_log) -> Nova.judge!(elk_log)
      true -> true
    end
  end
end
