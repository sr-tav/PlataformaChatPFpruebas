defmodule Mensaje do
  defstruct fecha: DateTime, sala_id: "", user_id: "", texto: ""

  def crear(fecha, sala_id, user_id, texto) do
    %Mensaje{fecha: fecha, sala_id: sala_id, user_id: user_id, texto: texto}
  end

  def leer_csv(nombre) do
    nombre
    |> File.stream!()
    |> Stream.drop(1)
    |> Enum.map(&convertir_cadena_mensaje/1)
  end

  def convertir_cadena_mensaje(cadena) do
    [fecha, sala_id, user_id, texto] = cadena
    |> String.split(";")
    |> Enum.map(&String.trim/1)
    Mensaje.crear(fecha, sala_id, user_id, texto)
  end

  def escribir_csv([], nombre), do: File.write!(nombre, "fecha;sala_id;user_id;texto\n")

  def escribir_csv(mensajes, nombre) do
    mensajes
    |>generar_mensajes(&convertir_mensaje_linea_csv/1)
    |>(&("fecha;sala_id;user_id;texto\n"<>&1)).()
    |>(&File.write(nombre,&1)).()
  end

  defp convertir_mensaje_linea_csv(mensaje) do
    "#{mensaje.fecha};#{mensaje.sala_id};#{mensaje.user_id};#{mensaje.texto}"
  end

  def generar_mensajes(lista_mensajes, parser) do
    lista_mensajes
    |>Enum.map(parser)
    |>Enum.join("\n")
  end
end
