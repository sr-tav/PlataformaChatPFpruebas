defmodule Util do

  def mostrar_mensaje_inspect(mensaje) do
    IO.inspect(mensaje)
  end

  def mostrar_mensaje(mensaje) do
    IO.puts("#{mensaje}")
  end

  def ingresar(mensaje, :texto) do
    mensaje
    |> IO.gets()
    |> String.trim()
  end

  def ingresar(mensaje, :entero) do
    mensaje
    try do
      mensaje
      |> Util.ingresar(:texto)
      |> String.to_integer()
    rescue
      ArgumentError ->
        "Error, se espera un entero\n"
      |> mostrar_error()

      mensaje
      |> ingresar(:entero)
    end
  end

  def ingresar(mensaje, :float) do
    mensaje
    try do
      mensaje
      |> Util.ingresar(:texto)
      |> String.to_float()
    rescue
      ArgumentError ->
        "Error, se espera un real\n"
      |> mostrar_error()

      mensaje
      |> ingresar(:float)
    end
  end

  def mostrar_error(mensaje) do
    IO.puts(:standard_error, mensaje)
  end

  def generarMensaje(nombre) do
    "Bienvenido #{nombre} a la empresa Once Ltda."
  end

end
