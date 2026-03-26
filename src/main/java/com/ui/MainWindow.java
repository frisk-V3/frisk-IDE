package com.ui;

import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.layout.BorderPane;
import javafx.stage.Stage;

public class MainWindow {

    private Stage stage;

    // FXML から読み込む UI パーツ
    public MenuBar menuBar;
    public TabPane editorTabs;
    public TextArea outputPane;
    public Label statusLabel;

    public MainWindow(Stage stage) {
        this.stage = stage;

        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/layout/main.fxml"));
            loader.setController(this);
            BorderPane root = loader.load();

            Scene scene = new Scene(root, 1400, 900);
            ThemeManager.apply(scene);

            stage.setScene(scene);
            stage.setTitle("frisk-IDE");
            stage.show();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void log(String text) {
        outputPane.appendText(text + "\n");
    }

    public void setStatus(String text) {
        statusLabel.setText(text);
    }
}
