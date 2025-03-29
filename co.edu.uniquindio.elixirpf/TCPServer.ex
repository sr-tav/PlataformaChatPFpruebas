defmodule TCPServer do
  @usuarios  [
    %{user: "pepito07", pass: "1234"},
    %{user: "user1", pass: "1234"}
  ]

  def start do
    {:ok, socket} = :gen_tcp.listen(4040, [:binary, packet: 4, active: false, reuseaddr: true, ip: {0, 0, 0, 0}])
    Util.mostrar_mensaje("Servidor TCP escuchando en el puerto 4040...")
    loop_accept(socket)
  end

  defp loop_accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Util.mostrar_mensaje("Cliente conectado")
    spawn(fn -> handle_client(client) end)
    loop_accept(socket)
  end

  defp handle_client(client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, mensaje} ->
        Util.mostrar_mensaje("Datos recibidos: #{mensaje}")
        respuesta = validar_credenciales(mensaje)

        :gen_tcp.send(client, "#{respuesta}\n")

        # 🔹 Esperamos a que Java termine de leer antes de cerrar
        :timer.sleep(10000)

      {:error, reason} ->
        Util.mostrar_mensaje("Error al recibir datos: #{reason}")
    end

    :gen_tcp.close(client)
  end

  defp validar_credenciales(mensaje) do
    case String.split(String.trim(mensaje), ",") do
      [usuario, contraseña] ->
        user_confirmado = Enum.find(@usuarios, fn u -> u.user == usuario end)
        pass_confirmado = Enum.find(@usuarios, fn u -> u.pass == contraseña end)
        if user_confirmado && pass_confirmado do
          "Acceso concedido"
        else
          "Acceso denegado"
        end

      _ ->
        "Formato incorrecto"
    end
  end
end

TCPServer.start()
