defmodule ServidorTCP do
  def iniciar do
    spawn(fn -> ejecutar_javafx() end)  # Ejecutar JavaFX en un proceso separado

    {:ok, socket} = :gen_tcp.listen(4040, [:binary, active: false, reuseaddr: true])
    IO.puts("Servidor TCP escuchando en el puerto 4040...")
    loop(socket)
  end

  defp ejecutar_javafx do
    IO.puts("Iniciando Javafx desde Elixir...")
    javafx_path = "C:/Users/tomaz/Downloads/openjfx-24_windows-x64_bin-sdk/javafx-sdk-24/lib"
    System.cmd("java", [
      "--module-path", javafx_path,
      "--add-modules", "javafx.controls,javafx.fxml",
      "-jar", "App.jar"
      ])
  end

  defp loop(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    IO.puts("Cliente conectado.")
    handle_client(client)
    loop(socket)
  end

  defp handle_client(client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data} ->
        IO.puts("Mensaje recibido: #{data}")
        :gen_tcp.send(client, "Mensaje recibido correctamente en Elixir!")
        :gen_tcp.close(client)

      {:error, _} -> IO.puts("Error recibiendo mensaje.")
    end
  end
end

ServidorTCP.iniciar()
