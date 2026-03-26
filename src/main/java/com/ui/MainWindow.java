package com.ui;

import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

import java.io.File;

public class MainWindow {

    private final Stage stage;

    public MenuBar menuBar;
    public TabPane editorTabs;
    public TextArea outputPane;
    public Label statusLabel;
    public VBox sideBar;

    private Explorer explorer;

    public MainWindow(Stage stage) {
        this.stage = stage;

        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/layout/main.fxml"));
            loader.setController(this);
            BorderPane root = loader.load();

            Scene scene = new Scene(root, 1400, 900);
            ThemeManager.apply(scene);

            stage.getIcons().add(IconLoader.loadLogo());
            stage.setScene(scene);
            stage.setTitle("frisk-IDE");
            stage.show();

            // Explorer を追加
            explorer = new Explorer(this);
            sideBar.getChildren().add(explorer);

            // 仮のプロジェクト読み込み
            explorer.loadProject(new File("project"));

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void openFile(java.nio.file.Path path) {
        // ここは frisk の EditorTab / EditorPane に合わせて実装してね
        System.out.println("Open file: " + path);
    }

    public void log(String text) {
        outputPane.appendText(text + "\n");
    }

    public void setStatus(String text) {
        statusLabel.setText(text);
    }

    public Scene getScene() {
        return stage.getScene();
    }
}
