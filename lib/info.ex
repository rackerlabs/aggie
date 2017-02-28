defmodule Aggie.Info do

  def start_link(name) do
    Agent.start_link(fn -> %{} end, name: name)
  end

  def get(name) do
    Agent.get(name, fn map -> map end)
  end

  def push(name, value) do
    Agent.update(name, fn map -> Map.merge(map,value) end)
  end

end
