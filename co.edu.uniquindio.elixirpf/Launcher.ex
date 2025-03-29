defmodule Launcher do
  def start do
    spawn(fn ->
      System.cmd("java", [
        "--module-path", "C:\\Users\\tomaz\\Downloads\\openjfx-24_windows-x64_bin-sdk\\javafx-sdk-24\\lib",
        "--add-modules", "javafx.controls,javafx.fxml",
        "-jar", "C:\\Users\\tomaz\\OneDrive\\Documentos\\Cositas mias\\Universidad\\Uni Quindio\\Cuarto Semestre\\Programacion3\\PlataformaChatPFpruebas\\co.edu.uniquindio.elixirpf\\demo\\target\\JavaFXApp.jar"
      ])
    end)
    TCPServer.start()
  end
end

Launcher.start()
