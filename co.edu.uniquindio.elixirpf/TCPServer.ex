defmodule TCPServer do
  def start do
    {:ok, listen_socket} = :gen_tcp.listen(4040, [:binary, reuseaddr: true])
    IO.puts("Servidor TCP escuchando en el puerto 4040...")
    loop_acceptor(listen_socket)
  end

  defp loop_acceptor(listen_socket) do
    {:ok, socket} = :gen_tcp.accept(listen_socket)
    IO.puts("Cliente conectado")
    handle_client(socket)
    IO.puts("Cliente entro y salio")
    loop_acceptor(listen_socket)
    IO.puts("Cliente entro2 y salio2")
  end

  defp handle_client(socket) do
    IO.puts("Cliente entro a handle")
    case :gen_tcp.recv(socket, 0) do
      {:ok, mensaje} ->
        IO.puts("Mensaje recibido: #{mensaje}")
        [usuario, contrasena] = String.split(mensaje, ",")
        respuesta = if validar_credenciales(usuario, contrasena), do: "Acceso concedido", else: "Acceso denegado"
        :gen_tcp.send(socket, respuesta <> "\n")
        :timer.sleep(10000)  # Simulación de espera
        :gen_tcp.close(socket)
      {:error, _} ->
        IO.puts("Error en la conexión con el cliente")
        :gen_tcp.close(socket)
    end
  end

  defp validar_credenciales(usuario, contrasena) do
    usuario == "admin" and contrasena == "1234"
  end
end
