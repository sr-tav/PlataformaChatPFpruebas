defmodule TCPServer do

  def start do
    SeguidorConexion.start_link([])
    {:ok, socket} = :gen_tcp.listen(4040, [:binary, packet: :line, active: false, reuseaddr: true, ip: {0,0,0,0}])

    IO.puts("Servidor TCP escuchando en el puerto 4040...")
    spawn(fn ->
      System.cmd("java", [
        "--module-path", "C:\\Users\\tomaz\\Downloads\\openjfx-24_windows-x64_bin-sdk\\javafx-sdk-24\\lib",
        "--add-modules", "javafx.controls,javafx.fxml",
        "-jar", "C:\\Users\\tomaz\\OneDrive\\Documentos\\Cositas mias\\Universidad\\Uni Quindio\\Cuarto Semestre\\Programacion3\\PlataformaChatPFpruebas\\co.edu.uniquindio.elixirpf\\demo\\target\\JavaFXApp.jar"
      ])
    end)
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    IO.puts("Esperando nueva conexión...")
    {:ok, cliente} = :gen_tcp.accept(socket)
    spawn(fn -> manejar_cliente(cliente) end)
    loop_acceptor(socket)
  end

  defp manejar_cliente(socket) do

    case :gen_tcp.recv(socket, 0) do
      {:ok, datos} ->
        IO.puts("Datos recibidos: #{inspect(datos)}")
        respuesta = procesar_mensaje(datos)
        :gen_tcp.send(socket, respuesta)
        IO.puts("Datos enviados: #{inspect(respuesta)}")
        manejar_cliente(socket)

      {:error, _reason} ->
        :gen_tcp.close(socket)

      {:error, :closed} ->
        IO.puts("Cliente desconectado")
        :gen_tcp.close(socket)
    end

  end

  defp procesar_mensaje(data) do

    case String.trim(data) do
      "usuarios_conectados" ->
        "#{SeguidorConexion.count()}\n"

      mensaje ->
        case String.split(mensaje, ",") do

          ["agregar_sala_user", user_id, sala_id] ->
            agregar_sala_user(user_id, sala_id)
            "Agregado\n"

          ["enviar_mensaje_sala", sala_id, user_id, contenido] ->
            guardar_mensaje(sala_id, user_id, contenido)
            "Mensaje enviado\n"

          ["nombre_user", user_id] ->
            "#{get_nombre_usuario(user_id)}\n"

          ["desconeccion", user, pass] ->
            modificar_usuarios_conectados("desconeccion", user, pass)
            "Desconectado\n"

          ["crear_sala", nombre, descripcion, user_id] ->
            crear_sala(nombre, descripcion, user_id)
            "Sala creada\n"

          ["obtener_not_salas", user_id] ->
            obtener_not_salas(user_id) <> "\n"

          ["obtener_salas", user_id] ->
            obtener_salas_user(user_id) <> "\n"

          ["nombre_sala", sala_id] ->
            obtener_nombre_sala(sala_id) <> "\n"

          ["nombre_sala_descripcion", sala_id] ->
            obtener_nombre_sala_descripcion(sala_id) <> "\n"

          ["actualizar_mensajes_sala", sala_id] ->
            obtener_mensajes_sala(sala_id) <> "\n"

          [user, pass] ->
            if validar_credenciales(user, pass) do
              user_id = get_user_id(user, pass)
              "Acceso concedido,#{user_id}\n"

            else
              "Acceso denegado\n"
            end
          _ ->
            "Comando no reconocido\n"
        end
    end

  end

  defp guardar_mensaje(sala_id, user_id, contenido) do
    ruta = "archivos_csv/sala_#{sala_id}/sala_#{sala_id}_mensajes.csv"
    mensajes = Mensaje.leer_csv(ruta)
    fecha = DateTime.utc_now() |> DateTime.to_iso8601()

    nuevo_mensaje = Mensaje.crear(fecha, sala_id, user_id, contenido)
    nuevos_mensajes = mensajes ++ [nuevo_mensaje]

    Mensaje.escribir_csv(nuevos_mensajes, ruta)
  end

  defp agregar_sala_user(sala_id, user_id) do
    Sala.agregar_user(sala_id, user_id)
  end

  defp obtener_not_salas(user_id) do
    usuario = Usuario.buscar_usuario(user_id)
    salas_usuario =
      case usuario.salas_id do
        "" -> []
        ids -> String.split(ids, "/")
      end

    todas_las_salas = Sala.leer_csv("archivos_csv/salas.csv")
    todas_las_salas
    |>Enum.filter(fn sala -> not(sala.sala_id in salas_usuario)end)
    |> Enum.map(& &1.sala_id)
    |> Enum.join("/")
  end

  defp obtener_mensajes_sala(sala_id) do
    "archivos_csv/sala_#{sala_id}/sala_#{sala_id}_mensajes.csv"
    |> Mensaje.leer_csv()
    |> Enum.map(fn msj -> "#{msj.fecha}~#{msj.user_id}~#{msj.texto}"end)
    |> Enum.join("|")
  end

  defp obtener_nombre_sala_descripcion(sala_id_2) do
    sala = Enum.find(Sala.leer_csv("archivos_csv/salas.csv"), fn sala_fn -> sala_fn.sala_id == sala_id_2 end)
    "#{sala.nombre},#{sala.descripcion}"
  end

  defp obtener_nombre_sala(sala_id_2) do
    sala = Enum.find(Sala.leer_csv("archivos_csv/salas.csv"), fn sala_fn -> sala_fn.sala_id == sala_id_2 end)
    "#{sala.nombre}"
  end

  defp obtener_salas_user(user_id) do
    persona = Enum.find(Usuario.leer_csv("archivos_csv/usuarios.csv"), fn usuario -> user_id == usuario.user_id end)
    persona.salas_id
  end

  defp get_user_id(user, pass) do
    persona = Enum.find(Usuario.leer_csv("archivos_csv/usuarios.csv"), fn usuario -> user == usuario.usuario && pass == usuario.contra end)
    persona.user_id
  end

  defp crear_sala(nombre,descripcion,user_id) do
    Sala.crear_auto(nombre, descripcion,user_id)
  end

  defp get_nombre_usuario(user_id) do
    case Enum.find(Usuario.leer_csv("archivos_csv/usuarios.csv"), fn usuario ->
         user_id == usuario.user_id
       end) do
    nil -> "Desconocido"
    user -> user.nombre
  end
  end

  defp validar_credenciales(user, pass) do
    spawn(fn -> modificar_usuarios_conectados("conectar", user, pass) end)
    Usuario.leer_csv("archivos_csv/usuarios.csv")
    |>Enum.any?(fn usuario -> user == usuario.usuario && pass == usuario.contra end)

  end

  defp modificar_usuarios_conectados("conectar", user, pass) do

    conectados = Usuario.leer_csv("archivos_csv/usuarios_conectados.csv")
    usuarios = Usuario.leer_csv("archivos_csv/usuarios.csv")

    usuario = Enum.find(usuarios, fn usuario -> user == usuario.usuario && pass == usuario.contra end)
    validacion = Enum.any?(conectados, fn usuario -> user == usuario.usuario && pass == usuario.contra end)

    if !validacion do
      nueva_lista = [usuario | conectados]
      SeguidorConexion.increment()
      Usuario.escribir_csv(nueva_lista, "archivos_csv/usuarios_conectados.csv")
    end
  end

  defp modificar_usuarios_conectados("desconeccion", user, pass) do
    conectados = Usuario.leer_csv("archivos_csv/usuarios_conectados.csv")
    usuarios = Usuario.leer_csv("archivos_csv/usuarios.csv")

    usuario = Enum.find(usuarios, fn usuario -> user == usuario.usuario && pass == usuario.contra end)
    validacion = Enum.any?(conectados, fn usuario -> user == usuario.usuario && pass == usuario.contra end)

    if validacion do
      nueva_lista = Enum.reject(conectados, fn pasa -> pasa.user_id == usuario.user_id end)
      SeguidorConexion.decrement()
      Usuario.escribir_csv(nueva_lista, "archivos_csv/usuarios_conectados.csv")
    end
  end

end
TCPServer.start()
