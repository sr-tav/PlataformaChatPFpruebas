defmodule Usuario do
  defstruct nombre: "", edad: 0, usuario: "", contra: "", user_id: ""

  def crear(nombre, edad,usuario,contra,user_id) do
    %Usuario{nombre: nombre, edad: edad, usuario: usuario, contra: contra, user_id: user_id}
  end

  def leer_csv(nombre) do
    nombre
    |> File.stream!()
    |> Stream.drop(1)
    |> Enum.map(&convertir_cadena_docente/1)
  end

  def convertir_cadena_docente(cadena) do
    [nombre,edad,usuario,contra,user_id] = cadena
    |> String.split(";")
    |> Enum.map(&String.trim/1)
    Usuario.crear(nombre, edad,usuario,contra,user_id)
  end

  def escribir_csv(usuarios, nombre) do
    usuarios
    |>generar_mensaje_clientes(&convertir_usuario_linea_csv/1)
    |>(&("nombre;edad;usuario;user_id\n"<>&1)).()
    |>(&File.write(nombre,&1)).()
  end

  defp convertir_usuario_linea_csv(usuario) do
    "#{usuario.nombre};#{usuario.edad};#{usuario.usuario};#{usuario.contra};#{usuario.user_id}"
  end

  def generar_mensaje_clientes(lista_usuarios, parser) do
    lista_usuarios
    |>Enum.map(parser)
    |>Enum.join("\n")
  end
end
