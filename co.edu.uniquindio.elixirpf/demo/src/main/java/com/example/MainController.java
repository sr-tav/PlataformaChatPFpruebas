package com.example;

import javafx.application.Platform;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.Socket;

public class MainController {
    @FXML
    private Button btnRecibir;
    @FXML
    private Label lblMensaje;

    @FXML
    void clickRecibir(ActionEvent event) {
        new Thread(() -> {
            try (Socket socket = new Socket("127.0.0.1", 4040);
                BufferedReader input = new BufferedReader(new InputStreamReader(socket.getInputStream()))) {

                String mensaje = input.readLine();  // Espera el mensaje del servidor

                Platform.runLater(() -> lblMensaje.setText(mensaje)); // Actualiza la UI en el hilo principal

            } catch (Exception e) {
                Platform.runLater(() -> lblMensaje.setText("Error de conexión"));
                e.printStackTrace();
            }
        }).start();
    }

}
