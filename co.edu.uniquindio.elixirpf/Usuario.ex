defmodule Usuario do
  defstruct nombre: "", edad: 0, usuario: "", contra: "", user_id: "", salas_id: ""

  def crear(nombre, edad,usuario,contra,user_id, salas_id) do
    %Usuario{nombre: nombre, edad: edad, usuario: usuario, contra: contra, user_id: user_id, salas_id: salas_id}
  end

  def leer_csv(nombre) do
    nombre
    |> File.stream!()
    |> Stream.drop(1)
    |> Enum.map(&convertir_cadena_docente/1)
  end

  def convertir_cadena_docente(cadena) do
    [nombre,edad,usuario,contra,user_id,salas_id] = cadena
    |> String.split(";")
    |> Enum.map(&String.trim/1)
    Usuario.crear(nombre, edad,usuario,contra,user_id,salas_id)
  end

  def escribir_csv(usuarios, nombre) do
    usuarios
    |>generar_mensaje_clientes(&convertir_usuario_linea_csv/1)
    |>(&("nombre;edad;usuario;contra;user_id;salas_id\n"<>&1)).()
    |>(&File.write(nombre,&1)).()
  end

  def escribir_csv([], nombre), do: File.write!(nombre, "nombre;edad;usuario;contra;user_id;salas_id\n")

  defp convertir_usuario_linea_csv(usuario) do
    "#{usuario.nombre};#{usuario.edad};#{usuario.usuario};#{usuario.contra};#{usuario.user_id};#{usuario.salas_id}"
  end

  def generar_mensaje_clientes(lista_usuarios, parser) do
    lista_usuarios
    |>Enum.map(parser)
    |>Enum.join("\n")
  end

  def buscar_usuario(user_id) do
    usuarios = leer_csv("archivos_csv/usuarios.csv")
    Enum.find(usuarios, fn usuario -> usuario.user_id == user_id end)
  end

  def agregar_salas(user_id, sala_id) do
  usuarios = leer_csv("archivos_csv/usuarios.csv")

  usuarios_actualizados = Enum.map(usuarios, fn usuario ->
    if usuario.user_id == user_id do
      nuevas_salas =
        case usuario.salas_id do
          "" -> sala_id
          salas -> "#{salas}/#{sala_id}"
        end

      %Usuario{usuario | salas_id: nuevas_salas}
    else
      usuario
    end
  end)
  escribir_csv(usuarios_actualizados, "archivos_csv/usuarios.csv")
end
end
