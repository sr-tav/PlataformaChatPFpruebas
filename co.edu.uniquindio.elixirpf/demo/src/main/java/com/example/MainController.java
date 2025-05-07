package com.example;

import javafx.application.Platform;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.Socket;

public class MainController {
    @FXML
    private Button btnRecibir;
    @FXML
    private Label lblMensaje;
    @FXML
    private TextField textPass;
    @FXML
    private TextField textUser;

    private String user;
    private String pass;

    @FXML
    void clickRecibir(ActionEvent event) {
        if (!textPass.getText().isEmpty() && !textUser.getText().isEmpty()) {
            new Thread(() -> {
                try (Socket socket = new Socket("127.0.0.1", 4040);
                    BufferedReader input = new BufferedReader(new InputStreamReader(socket.getInputStream()));
                    BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream()))) {

                        String datos = textUser.getText() + "," + textPass.getText();
                        System.out.println("Mensaje enviado: " + datos);  // <-- IMPRIME LO QUE SE ENVÍA

                        writer.write(datos);
                        writer.newLine();
                        writer.flush();  // Asegurar que se envía

                        // Leer respuesta del servidor
                        String mensaje = input.readLine();
                        System.out.println("Mensaje recibido: " + mensaje);  // <-- IMPRIME LO QUE RECIBE
                
                        Platform.runLater(() -> lblMensaje.setText(mensaje));


                        if ("Acceso concedido".equals(mensaje)) {
                            this.user = textUser.getText();
                            this.pass = textPass.getText();
                            Platform.runLater(() -> {
                                try {
                                    abrirDashboard();
                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                            });
                        }
                        Thread.sleep(10000);

                        writer.close();
                        input.close();
                        socket.close();
    
                } catch (Exception e) {
                    Platform.runLater(() -> lblMensaje.setText("Error de conexión"));
                    e.printStackTrace();
                }
            }).start();
        }else{
            lblMensaje.setText("Llene los espacios vacios");
        }
    }
    public void abrirDashboard() throws IOException{
        FXMLLoader loader = new FXMLLoader(getClass().getResource("/com/example/Dashboard.fxml"));
        Parent root = loader.load(); // carga primero
        DashboardviewController controller = loader.getController(); // ahora sí puedes obtenerlo
        controller.setPass(pass);
        controller.setUser(user);
        Scene scene = new Scene(root, 600, 400);
        Stage stage = new Stage();
        stage.setScene(scene);
        stage.show();
    }

}
