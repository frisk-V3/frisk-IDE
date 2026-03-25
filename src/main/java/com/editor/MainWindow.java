package com.ui;

import com.core.ProjectManager;
import com.editor.*;
import com.languages.*;

import javafx.scene.Scene;
import javafx.scene.control.TabPane;
import javafx.stage.Stage;

import java.nio.file.Path;

public class MainWindow {

    private final Stage stage;
    private final TabPane tabs = new TabPane();
    private final ProjectManager projects = new ProjectManager();

    public MainWindow(Stage stage) {
        this.stage = stage;

        stage.setTitle("frisk-IDE");
        stage.setScene(new Scene(tabs, 1400, 900));
        stage.show();
    }

    public void openFile(Path path) throws Exception {
        var lang = LanguageDetector.detect(path);
        var doc = new EditorDocument(path);
        var highlighter = new SyntaxHighlighter(lang);
        var completion = new CompletionProvider(lang);

        var editor = new EditorPane(doc, highlighter, completion);
        var tab = new EditorTab(editor, path.getFileName().toString());

        tabs.getTabs().add(tab);
        tabs.getSelectionModel().select(tab);
    }
}
