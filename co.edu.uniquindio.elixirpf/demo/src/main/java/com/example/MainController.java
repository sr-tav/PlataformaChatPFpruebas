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
import javafx.stage.StageStyle;
import java.io.IOException;

public class MainController {

    @FXML
    private Button btnRecibir;

    @FXML
    private Label lblMensaje;

    @FXML
    private TextField textPass;

    @FXML
    private TextField textUser;

    @FXML
    private Button btnRegistrar;

    private String user;
    private String pass;
    private String user_id;
    /**
     * Metodo que al darle click al boton Sign in en el login, envia al server la info del login
     * y retorna un probatorio y un user_id para luego desplegar la ventana dashboard
     * @param event
     */
    @FXML
    void clickRecibir(ActionEvent event) {
        if (!textPass.getText().isEmpty() && !textUser.getText().isEmpty()) {
            new Thread(() -> {
                try {
                        String datos = textUser.getText() + "," + textPass.getText();
                        String mensaje_cript = SocketCliente.getInstancia().enviarComando(CryptoUtil.getInstance().encriptar(datos));
                        String mensaje = CryptoUtil.getInstance().desencriptar(mensaje_cript);

                        String[] partes = mensaje.split(",",2);
                        String parte1 = partes[0].trim();
                        String parte2 = partes.length > 1 ? partes[1].trim() : "";
        
                        Platform.runLater(() -> lblMensaje.setText(mensaje));


                        if ("Acceso concedido".equals(parte1)) {
                            this.user = textUser.getText();
                            this.pass = textPass.getText();
                            this.user_id = parte2;
                            Platform.runLater(() -> {
                                try {
                                    abrirDashboard();
                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                            });
                        }
    
                } catch (Exception e) {
                    Platform.runLater(() -> lblMensaje.setText("Error de conexión"));
                    e.printStackTrace();
                }
            }).start();
        }else{
            lblMensaje.setText("Llene los espacios vacios");
        }
    }
    /**
     * Metodo que abre la ventana Dashboard y la inicializa
     * @throws IOException
     */
    public void abrirDashboard() throws IOException{
        FXMLLoader loader = new FXMLLoader(getClass().getResource("/com/example/Dashboard.fxml"));
        Parent root = loader.load();

        DashboardviewController controller = loader.getController();
       
        controller.setPass(this.pass);
        controller.setUser(this.user);
        controller.setUser_id(user_id);
        controller.inicializar();
        
        Scene scene = new Scene(root, 818, 558);
        Stage stage = new Stage();

        stage.setScene(scene);

        Stage StageCerrar = (Stage) btnRegistrar.getScene().getWindow();
        StageCerrar.close();

        stage.initStyle(StageStyle.UNDECORATED);
        stage.show();
    }
    /**
     * Metodo que al darle click al boton Sign up, abre el formulario de registro de un nuevo
     * usuario
     * @param event
     */
    @FXML
    void clickRegistrar(ActionEvent event) {

    }

}
