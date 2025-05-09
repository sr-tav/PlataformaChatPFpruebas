package com.example;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;
import javafx.stage.StageStyle;

import java.io.IOException;

/**
 * JavaFX App
 */
public class App extends Application {

    @Override
    public void start(Stage stage) throws IOException {
        /* 
        FXMLLoader loader =  new FXMLLoader(getClass().getResource("/com/example/Dashboard.fxml"));
        stage.setScene(new Scene(loader.load(), 818, 558));
        stage.setTitle("JavaFX y Elixir");
        stage.initStyle(StageStyle.UNDECORATED);
        stage.show();
        */
        
        FXMLLoader loader =  new FXMLLoader(getClass().getResource("Main.fxml"));
        stage.setScene(new Scene(loader.load(), 349, 645));
        stage.setTitle("JavaFX y Elixir");
        stage.show();
        
    }
    public static void main(String[] args) {
        launch();
    }

}