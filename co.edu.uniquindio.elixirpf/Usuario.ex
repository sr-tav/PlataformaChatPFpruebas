defmodule Usuario do
  defstruct nombre: "", edad: 0, usuario: "", contra: ""

  def crear(nombre, edad,usuario,contra) do
    %Usuario{nombre: nombre, edad: edad, usuario: usuario, contra: contra}
  end

end
