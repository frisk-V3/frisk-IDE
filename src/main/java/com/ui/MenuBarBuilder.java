package com.ui;

import javafx.scene.control.Menu;
import javafx.scene.control.MenuBar;
import javafx.scene.control.MenuItem;

public class MenuBarBuilder {

    public static MenuBar create(MainWindow window) {

        Menu file = new Menu("File");

        Menu build = new Menu("Build");

        MenuItem buildProject = new MenuItem("Build Project");
        buildProject.setOnAction(e -> {
            var tab = window.getActiveEditorTab();
            if (tab != null) window.buildManager().build(tab.project());
        });

        MenuItem runProject = new MenuItem("Run Project");
        runProject.setOnAction(e -> {
            var tab = window.getActiveEditorTab();
            if (tab != null) window.buildManager().run(tab.project());
        });

        build.getItems().addAll(buildProject, runProject);

        return new MenuBar(file, build);
    }
}
