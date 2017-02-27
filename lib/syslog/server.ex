defmodule Aggie.SyslogServer do
  alias Aggie.Shipper
  alias Aggie.Judge

  def listen(port) do
    tcp_options = [:list, {:packet, 0}, {:active, false}, {:reuseaddr, true}]
    {:ok, socket} = :gen_tcp.listen(port, tcp_options)
    do_listen(socket)
  end

  defp do_listen(l_socket) do
    {:ok, socket} = :gen_tcp.accept(l_socket)
    spawn(fn() -> do_server(socket) end)
    do_listen(l_socket)
  end

  defp do_server(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:error, :closed} -> :ok
      {:ok, data} ->
        case Judge.verdict?(data) do
          true -> Shipper.ship!(data)
        end

        do_server(socket)
    end
  end
end
