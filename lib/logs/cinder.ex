require IEx

defmodule Aggie.Logs.Cinder do

  def is_cinder?(elk_log) do
    elk_log["_source"]["tags"] |> Enum.member?("cinder")
  end

  def judge!(elk_log) do
  end

  def success?(elk_log) do
  end

  def failure?(elk_log) do
  end

end
