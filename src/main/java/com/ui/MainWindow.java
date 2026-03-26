package com.ui;

import com.editor.EditorTab;
import com.project.Project;
import com.project.ProjectDetector;
import com.build.BuildManager;

import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

import java.io.File;
import java.nio.file.Path;

public class MainWindow {

    private final Stage stage;

    public MenuBar menuBar;
    public TabPane editorTabs;
    public TextArea outputPane;
    public Label statusLabel;
    public VBox sideBar;

    private Explorer explorer;

    private Project activeProject;
    private BuildManager buildManager = new BuildManager();

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

            // Explorer
            explorer = new Explorer(this);
            sideBar.getChildren().add(explorer);

            // プロジェクト読み込み
            File projectDir = new File("project");
            if (projectDir.exists()) {
                explorer.loadProject(projectDir);

                // プロジェクト判定
                activeProject = ProjectDetector.detect(projectDir.toPath());
                if (activeProject != null) {
                    log("Loaded project: " + activeProject.language());
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            log("Failed to initialize MainWindow");
        }
    }

    // -----------------------------
    // ファイルをエディタで開く
    // -----------------------------
    public void openFile(Path path) {
        try {
            for (Tab t : editorTabs.getTabs()) {
                if (t.getText().equals(path.getFileName().toString())) {
                    editorTabs.getSelectionModel().select(t);
                    return;
                }
            }

            EditorTab tab = new EditorTab(path);
            editorTabs.getTabs().add(tab);
            editorTabs.getSelectionModel().select(tab);

            setStatus("Opened: " + path.getFileName());

        } catch (Exception e) {
            e.printStackTrace();
            log("Failed to open file: " + path);
        }
    }

    // -----------------------------
    // Build
    // -----------------------------
    public void buildProject() {
        if (activeProject == null) {
            log("No project loaded.");
            return;
        }

        log("Building project...");
        buildManager.build(activeProject);
    }

    // -----------------------------
    // Run
    // -----------------------------
    public void runProject() {
        if (activeProject == null) {
            log("No project loaded.");
            return;
        }

        log("Running project...");
        buildManager.run(activeProject);
    }

    // -----------------------------
    // ログ出力
    // -----------------------------
    public void log(String text) {
        outputPane.appendText(text + "\n");
    }

    // -----------------------------
    // ステータスバー更新
    // -----------------------------
    public void setStatus(String text) {
        statusLabel.setText(text);
    }

    public Scene getScene() {
        return stage.getScene();
    }
}
