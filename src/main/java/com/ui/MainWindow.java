package com.ui;

import javafx.scene.Scene;
import javafx.scene.control.BorderPane;
import javafx.stage.Stage;

public class MainWindow {

    private final Stage stage;
    private final BorderPane root = new BorderPane();

    public MainWindow(Stage stage) {
        this.stage = stage;

        Scene scene = new Scene(root, 1400, 900);
        ThemeManager.apply(scene); // ★ テーマ適用させる

        stage.setScene(scene);
        stage.setTitle("frisk-IDE");
        stage.show();
    }

    public Scene getScene() {
        return stage.getScene();
    }
}
