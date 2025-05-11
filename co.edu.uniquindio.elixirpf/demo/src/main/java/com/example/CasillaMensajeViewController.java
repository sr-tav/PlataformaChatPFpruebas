package com.example;

import javafx.fxml.FXML;
import javafx.scene.control.Label;

public class CasillaMensajeViewController {
    
    @FXML
    private Label labelHora;

    @FXML
    private Label labelMensaje;

    @FXML
    private Label labelUsuario;

    public void setData(String fecha, String mensaje, String usuario){
        labelHora.setText(fecha);
        labelMensaje.setText(mensaje);
        labelUsuario.setText(usuario);
    }
}
