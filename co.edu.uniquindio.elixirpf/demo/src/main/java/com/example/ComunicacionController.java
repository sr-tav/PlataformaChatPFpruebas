package com.example;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.Socket;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;

public class ComunicacionController {
    @FXML
    private Button btnClick;

    @FXML
    private Label text;

    @FXML
    void clickComunicar(ActionEvent event) {
        try (Socket socket = new Socket("localhost", 4040);
             OutputStream output = socket.getOutputStream();
             PrintWriter writer = new PrintWriter(output, true);
             BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream()))) {

            // Enviar mensaje a Elixir
            writer.println("Hola desde JavaFX!");

            // Leer respuesta de Elixir
            String respuesta = reader.readLine();
            text.setText(respuesta);  // Mostrar respuesta en la UI

        } catch (Exception e) {
            text.setText("Error en comunicación");
            e.printStackTrace();
        }
    }
}