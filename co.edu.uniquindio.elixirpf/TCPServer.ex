defmodule TCPServer do

  def start do
    SeguidorConexion.start_link([])
    {:ok, listen_socket} = :gen_tcp.listen(4040, [:binary, packet: :line, active: false, reuseaddr: true, ip: {0,0,0,0}])

    IO.puts("Servidor TCP escuchando en el puerto 4040...")
    spawn(fn ->
      System.cmd("java", [
        "--module-path", "C:\\Users\\tomaz\\Downloads\\openjfx-24_windows-x64_bin-sdk\\javafx-sdk-24\\lib",
        "--add-modules", "javafx.controls,javafx.fxml",
        "-jar", "C:\\Users\\tomaz\\OneDrive\\Documentos\\Cositas mias\\Universidad\\Uni Quindio\\Cuarto Semestre\\Programacion3\\PlataformaChatPFpruebas\\co.edu.uniquindio.elixirpf\\demo\\target\\JavaFXApp.jar"
      ])
    end)
    loop_acceptor(listen_socket)
  end
  defp loop_acceptor(listen_socket) do
    IO.puts("Esperando nueva conexión...")

    case :gen_tcp.accept(listen_socket, 5000) do
      {:ok, socket} ->
        IO.puts("Cliente conectado")
        :ok = :inet.setopts(socket, [active: false, packet: :line])
        spawn(fn -> saludo_client(socket) end)
        loop_acceptor(listen_socket)

      {:error, :timeout} ->
        IO.puts("Timeout en accept, reintentando...")
        loop_acceptor(listen_socket)

      {:error, reason} ->
        IO.puts("Error crítico en accept: #{reason}")
        Process.sleep(1000)
        start()
    end
  end

  defp saludo_client(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        IO.puts("Datos recibidos: #{inspect(data)}")
        respuesta = procesar_mensaje(data)
        :gen_tcp.send(socket, respuesta)
        :gen_tcp.close(socket)

      {:error, reason} ->
        IO.puts("Error en recepción: #{reason}")
        :gen_tcp.close(socket)
    end
  end

  defp procesar_mensaje(data) do
    case String.trim(data) do
      "usuarios_conectados" ->
        "#{SeguidorConexion.count()}\n"

      _ ->
        case String.split(String.trim(data), ",") do
          [user, pass] ->
            if validar_credenciales(user, pass) do
              SeguidorConexion.increment()
              "Acceso concedido\n"
            else
              "Acceso denegado\n"
            end
          ["nombre_user", user, pass] ->
            "#{get_nombre_usuario(user, pass)}\n"

        end
    end
  end
  defp get_nombre_usuario(user, pass) do
    user = Enum.find(Usuario.leer_csv("archivos_csv/usuarios.csv"), fn usuario -> user == usuario.usuario && pass == usuario.contra end)
    user.nombre
  end
  defp validar_credenciales(user, pass) do
    Usuario.leer_csv("archivos_csv/usuarios.csv")
    |>Enum.any?(fn usuario -> user == usuario.usuario && pass == usuario.contra end)
  end
end
TCPServer.start()
