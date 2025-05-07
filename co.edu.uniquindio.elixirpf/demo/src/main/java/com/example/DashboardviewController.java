package com.example;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.Socket;
import java.net.URL;
import java.util.ResourceBundle;

import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;

public class DashboardviewController implements Initializable{
    private String user;
    private String pass;
    @FXML
    private Label lblNumConectados;

    @Override
    public void initialize(URL arg0, ResourceBundle arg1) {
        new Thread(() -> {
            while (true) {
                try (Socket socket = new Socket("127.0.0.1", 4040);
                     BufferedReader input = new BufferedReader(new InputStreamReader(socket.getInputStream()));
                     BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream()))) {
    
                    writer.write("usuarios_conectados\n");
                    writer.flush();
    
        
                    String mensaje = input.readLine();
                    Platform.runLater(() -> lblNumConectados.setText(mensaje));
    
                } catch (Exception e) {
                    Platform.runLater(() -> lblNumConectados.setText("Error de conexión"));
                    e.printStackTrace();
                }
    
                try {
                    Thread.sleep(10000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }
    
    /**
     * 
     * 
     */
    public String getUser() {
        return user;
    }
    public void setUser(String user) {
        this.user = user;
    }
    public String getPass() {
        return pass;
    }
    public void setPass(String pass) {
        this.pass = pass;
    }
    public Label getLblNumConectados() {
        return lblNumConectados;
    }
    public void setLblNumConectados(Label lblNumConectados) {
        this.lblNumConectados = lblNumConectados;
    }
    
    
}

