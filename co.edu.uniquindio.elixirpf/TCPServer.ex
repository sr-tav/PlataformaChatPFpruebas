defmodule TCPServer do
  # --------------------------- Metodo para iniciar el servidor y mostrar la vista JavaFX para control ----------------------------------
  # @param
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
  # --------------------------- Loop recursivo para recibir nuevos clientes en el servidor ----------------------------------
  # @param = socket
  defp loop_acceptor(socket) do
    IO.puts("Esperando nueva conexión...")
    {:ok, cliente} = :gen_tcp.accept(socket)
    spawn(fn -> manejar_cliente(cliente) end)
    loop_acceptor(socket)
  end
  # --------------------------- Gestion de un proceso unico para cada cliente ----------------------------------
  # @param = socket
  defp manejar_cliente(socket) do

    case :gen_tcp.recv(socket, 0) do
      {:ok, datos} ->
        IO.puts("Datos recibidos: #{inspect(datos)}")
        mensaje = Encriptador.desencriptar(String.trim(datos))
        IO.puts(mensaje)
        respuesta = procesar_mensaje(mensaje)
        respuesta_encriptada = "#{Encriptador.encriptar(respuesta)}\n"
        :gen_tcp.send(socket, respuesta_encriptada)
        IO.puts("Datos enviados: #{inspect(respuesta)}")
        ##IO.puts("Datos crip enviados: #{inspect(respuesta_encriptada)}")
        manejar_cliente(socket)

      {:error, _reason} ->
        :gen_tcp.close(socket)

      {:error, :closed} ->
        IO.puts("Cliente desconectado")
        :gen_tcp.close(socket)
    end

  end
  # --------------------------- Procesamiento de mensajes que vienen del cliente ----------------------------------
  # @param = datos que envio el cliente
  defp procesar_mensaje(data) do

    case String.trim(data) do
      "usuarios_conectados" ->
        "#{SeguidorConexion.count()}"

      mensaje ->
        case String.split(mensaje, ",") do
          ["crear_usuario", nombre, edad, usuario, contra] ->
            user_id = crear_usuario(nombre,edad,usuario,contra)
            "Usuario creado,#{user_id}"

          ["agregar_sala_user", user_id, sala_id] ->
            agregar_sala_user(user_id, sala_id)
            "Agregado"

          ["enviar_mensaje_sala", sala_id, user_id, contenido] ->
            guardar_mensaje(sala_id, user_id, contenido)
            "Mensaje enviado"

          ["nombre_user", user_id] ->
            "#{get_nombre_usuario(user_id)}"

          ["desconeccion", user, pass] ->
            modificar_usuarios_conectados("desconeccion", user, pass)
            "Desconectado"

          ["crear_sala", nombre, descripcion, user_id] ->
            crear_sala(nombre, descripcion, user_id)
            "Sala creada"

          ["obtener_not_salas", user_id] ->
            obtener_not_salas(user_id)

          ["obtener_salas", user_id] ->
            obtener_salas_user(user_id)

          ["nombre_sala", sala_id] ->
            obtener_nombre_sala(sala_id)

          ["nombre_sala_descripcion", sala_id] ->
            obtener_nombre_sala_descripcion(sala_id)

          ["actualizar_mensajes_sala", sala_id] ->
            obtener_mensajes_sala(sala_id)

          ["salir_sala_user_id", sala_id, user_id] ->
            salir_sala(sala_id, user_id)
            "Sacado de la sala"

          [user, pass] ->

            if validar_credenciales(String.trim(user), String.trim(pass)) do
              user_id = get_user_id(user, pass)
              "Acceso concedido,#{user_id}"

            else
              "Acceso denegado"
            end
          _ ->
            "Comando no reconocido"
        end
    end

  end
  # --------------------------- Crear un nuevo usuario ----------------------------------
  # @param = nombre / edad / usuario / contrasena
  defp crear_usuario(nombre,edad,usuario,contra) do
    user_id = Usuario.crear_auto(nombre,edad,usuario,contra)
    modificar_usuarios_conectados("conectar", usuario, contra)
    user_id
  end
  # --------------------------- Sacar de una sala un usuario teniendo sala_id y user_id ----------------------------------
  # @param = sala_id / user_id
  defp salir_sala(sala_id, user_id) do
    Sala.eliminar_user(sala_id, user_id)
  end
  # --------------------------- Obtener todas las salas a las que no esta inscrito un usuario ----------------------------------
  # @param = sala_id / user_id / contenido del mensaje
  defp guardar_mensaje(sala_id, user_id, contenido) do
    ruta = "archivos_csv/sala_#{sala_id}/sala_#{sala_id}_mensajes.csv"
    mensajes = Mensaje.leer_csv(ruta)
    fecha = DateTime.utc_now() |> DateTime.to_iso8601()

    nuevo_mensaje = Mensaje.crear(fecha, sala_id, user_id, contenido)
    nuevos_mensajes = mensajes ++ [nuevo_mensaje]

    Mensaje.escribir_csv(nuevos_mensajes, ruta)
  end
  # --------------------------- Incribir un usuario a una sala teniendo sala_id y user_id ----------------------------------
  # @param = sala_id / user_id
  defp agregar_sala_user(sala_id, user_id) do
    Sala.agregar_user(sala_id, user_id)
  end
  # --------------------------- Obtener todas las salas a las que no esta inscrito un usuario ----------------------------------
  # @param = sala_id
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
  # --------------------------- Obtener todos los mensajes de una sala teniendo el sala_id ----------------------------------
  # @param = sala_id
  defp obtener_mensajes_sala(sala_id) do
    "archivos_csv/sala_#{sala_id}/sala_#{sala_id}_mensajes.csv"
    |> Mensaje.leer_csv()
    |> Enum.map(fn msj -> "#{msj.fecha}~#{msj.user_id}~#{msj.texto}"end)
    |> Enum.join("|")
  end
  # --------------------------- obtener nombre de la sala y la descripcion por sala_id ----------------------------------
  # @param = sala_id
  defp obtener_nombre_sala_descripcion(sala_id_2) do
    sala = Enum.find(Sala.leer_csv("archivos_csv/salas.csv"), fn sala_fn -> sala_fn.sala_id == sala_id_2 end)
    "#{sala.nombre},#{sala.descripcion}"
  end
  # --------------------------- Obtener nombre de sala por sala_id ----------------------------------
  # @param = sala_id
  defp obtener_nombre_sala(sala_id_2) do
    sala = Enum.find(Sala.leer_csv("archivos_csv/salas.csv"), fn sala_fn -> sala_fn.sala_id == sala_id_2 end)
    "#{sala.nombre}"
  end
  # --------------------------- Modificar el csv de usuarios conectados, caso: coneccion ----------------------------------
  # @param = user_id
  defp obtener_salas_user(user_id) do
    persona = Enum.find(Usuario.leer_csv("archivos_csv/usuarios.csv"), fn usuario -> user_id == usuario.user_id end)
    persona.salas_id
  end
  # --------------------------- obtener el user_id por credenciales ----------------------------------
  # @param = user / pass
  defp get_user_id(user, pass) do
    persona = Enum.find(Usuario.leer_csv("archivos_csv/usuarios.csv"), fn usuario -> user == usuario.usuario && pass == usuario.contra end)
    persona.user_id
  end
  # --------------------------- Crear nueva sala  ----------------------------------
  # @param = nombre / descripcion / user_id
  defp crear_sala(nombre,descripcion,user_id) do
    Sala.crear_auto(nombre, descripcion,user_id)
  end
  # --------------------------- Obtener nombre del usuario por user_id ----------------------------------
  # @param = user_id
  defp get_nombre_usuario(user_id) do
    case Enum.find(Usuario.leer_csv("archivos_csv/usuarios.csv"), fn usuario ->
         user_id == usuario.user_id
       end) do
    nil -> "Desconocido"
    user -> user.nombre
  end
  end
  # --------------------------- validar credenciales ----------------------------------
  # @param = user / pass
  defp validar_credenciales(user, pass) do
    spawn(fn -> modificar_usuarios_conectados("conectar", user, pass) end)
    Usuario.leer_csv("archivos_csv/usuarios.csv")
    |>Enum.any?(fn usuario -> user == usuario.usuario && pass == usuario.contra end)

  end
  # --------------------------- Modificar el csv de usuarios conectados, caso: coneccion ----------------------------------
  # @param = "conectar"/ user / pass
  defp modificar_usuarios_conectados("conectar", user, pass) do
    IO.inspect(user, label: "usuario")
    IO.inspect(pass, label: "contrase")

    conectados = Usuario.leer_csv("archivos_csv/usuarios_conectados.csv")
    usuarios = Usuario.leer_csv("archivos_csv/usuarios.csv")

    usuario_found = Enum.find(usuarios, fn usuario -> user == usuario.usuario && pass == usuario.contra end)
    validacion = Enum.any?(conectados, fn usuario -> user == usuario.usuario && pass == usuario.contra end)

    if !validacion and usuario_found != nil do
      nueva_lista = [usuario_found | conectados]
      SeguidorConexion.increment()
      Usuario.escribir_csv(nueva_lista, "archivos_csv/usuarios_conectados.csv")
    end
  end
  # -------------------------- Modificar el csv de usuarios conectados, caso: desconeccion -------------------------------
  # @param = "desconeccion"/ user / pass
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
