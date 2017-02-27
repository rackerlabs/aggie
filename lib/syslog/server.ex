defmodule Aggie.SyslogServer do
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
      {:ok, data} ->
        :gen_tcp.send(socket, data)
        IO.puts(data)
        do_server(socket)
      {:error, :closed} -> :ok
    end
  end
end
