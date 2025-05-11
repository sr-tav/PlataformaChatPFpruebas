defmodule Sala do
  defstruct nombre: "", sala_id: "", mensajes: "", usuarios: "", descripcion: ""

  def crear(nombre, sala_id, mensajes, usuarios, descripcion) do
    %Sala{nombre: nombre, sala_id: sala_id, mensajes: mensajes, usuarios: usuarios, descripcion: descripcion}
  end

  def crear_auto(nombre, descripcion, user_id) do
    sala_id = generar_id_unico("archivos_csv/salas.csv")

    carpeta = "archivos_csv/sala_#{sala_id}"
    File.mkdir(carpeta)

    Usuario.agregar_salas(user_id,sala_id)
    usuario_creador = Usuario.buscar_usuario(user_id)
    mensajes = Mensaje.escribir_csv([],"archivos_csv/sala_#{nombre}_#{sala_id}/sala_#{sala_id}_mensajes.csv")
    usuarios = Usuario.escribir_csv([usuario_creador],"archivos_csv/sala_#{nombre}_#{sala_id}/sala_#{sala_id}_usuarios.csv")

    nueva_sala = crear(nombre, sala_id, mensajes, usuarios, descripcion)
    salas = leer_csv("archivos_csv/salas.csv")

    escribir_csv([nueva_sala | salas], "archivos_csv/salas.csv")
    sala_id
  end

  def leer_csv(nombre) do
    nombre
    |> File.stream!()
    |> Stream.drop(1)
    |> Enum.map(&convertir_cadena_sala/1)
  end

  def convertir_cadena_sala(cadena) do
    [nombre, sala_id, mensajes, usuarios, descripcion] = cadena
    |> String.split(";")
    |> Enum.map(&String.trim/1)
    Sala.crear(nombre,sala_id,mensajes,usuarios, descripcion)
  end

  def escribir_csv(salas, nombre) do
    salas
    |>generar_mensaje_sala(&convertir_sala_linea_csv/1)
    |>(&("nombre;sala_id;mensajes;usuarios;descripcion\n"<>&1)).()
    |>(&File.write(nombre,&1)).()
  end

  defp convertir_sala_linea_csv(sala) do
    "#{sala.nombre};#{sala.sala_id};#{sala.mensajes};#{sala.usuarios};#{sala.descripcion}"
  end

  def generar_mensaje_sala(lista_salas, parser) do
    lista_salas
    |>Enum.map(parser)
    |>Enum.join("\n")
  end

  def generar_id_unico(ruta_csv) do
    salas = leer_csv(ruta_csv)
    ids_existentes = Enum.map(salas, fn %Sala{sala_id: id} -> id end)
    Stream.iterate(1, &(&1 + 1))
    |> Enum.find(fn id -> not (Integer.to_string(id) in ids_existentes) end)
    |> Integer.to_string()
  end

  def agregar_user(sala_id, user_id) do
    Usuario.agregar_salas(user_id, sala_id)
    user = Usuario.buscar_usuario(user_id)
    usuarios = Usuario.leer_csv("archivos_csv/sala_#{sala_id}/sala_#{sala_id}_usuarios.csv")
    nuevos_usuarios = [user|usuarios]
    Usuario.escribir_csv(nuevos_usuarios, "archivos_csv/sala_#{sala_id}/sala_#{sala_id}_usuarios.csv")
  end
end
