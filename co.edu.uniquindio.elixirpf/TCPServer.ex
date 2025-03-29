defmodule TCPServer do
  def start do
    {:ok, socket} = :gen_tcp.listen(4040, [:binary, packet: 4, active: false, reuseaddr: true])
    IO.puts("Servidor TCP escuchando en el puerto 4040...")
    loop_accept(socket)
  end

  defp loop_accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    IO.puts("Cliente conectado")

    # Enviar mensaje al cliente (JavaFX)
    :gen_tcp.send(client, "saludo desde elixir")
    :gen_tcp.close(client)
    # Mantener la conexión activa
    loop_accept(socket)
  end
end
