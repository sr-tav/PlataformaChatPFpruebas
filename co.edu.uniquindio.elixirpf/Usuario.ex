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

  def crear_auto(nombre,edad,usuario,contra) do
    usuarios = leer_csv("archivos_csv/usuarios.csv")
      ids_existentes =
        usuarios
        |> Enum.map(& &1.user_id)
        |> Enum.filter(&(&1 != ""))
        |> Enum.map(&String.to_integer/1)

      nuevo_id =
        if ids_existentes == [] do
          "1"
        else
          (Enum.max(ids_existentes) + 1)
          |> Integer.to_string()
        end

      nuevo_usuario = Usuario.crear(nombre, edad, usuario, contra, nuevo_id, "")
      nuevos_usuarios = [nuevo_usuario | usuarios]
      escribir_csv(nuevos_usuarios, "archivos_csv/usuarios.csv")
      nuevo_id;
  end

  def convertir_cadena_docente(cadena) do
    [nombre,edad,usuario,contra,user_id,salas_id] = cadena
    |> String.split(";")
    |> Enum.map(&String.trim/1)
    Usuario.crear(nombre, edad,usuario,contra,user_id,salas_id)
  end

  def escribir_csv([], nombre), do: File.write!(nombre, "nombre;edad;usuario;contra;user_id;salas_id\n")

  def escribir_csv(usuarios, nombre) do
    usuarios
    |>generar_mensaje_clientes(&convertir_usuario_linea_csv/1)
    |>(&("nombre;edad;usuario;contra;user_id;salas_id\n"<>&1)).()
    |>(&File.write(nombre,&1)).()
  end

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
  def eliminar_sala(sala_id, user_id) do
    usuarios = leer_csv("archivos_csv/usuarios.csv")

    usuarios_actualizados = Enum.map(usuarios, fn usuario ->
      if usuario.user_id == user_id do
        nuevas_salas =
          usuario.salas_id
          |> String.split("/", trim: true)
          |> Enum.reject(&(&1 == sala_id))
          |> Enum.join("/")

        %Usuario{usuario | salas_id: nuevas_salas}
      else
        usuario
      end
    end)
    escribir_csv(usuarios_actualizados, "archivos_csv/usuarios.csv")
  end
end
