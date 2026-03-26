package com.ui;

import javafx.scene.control.Button;
import javafx.scene.control.ToolBar;

public class ToolBarBuilder {

    public static ToolBar create(MainWindow window) {

        Button build = new Button("Build");
        build.setOnAction(e -> {
            var project = window.getActiveProject();
            if (project != null) window.buildManager().build(project);
        });

        Button run = new Button("Run");
        run.setOnAction(e -> {
            var project = window.getActiveProject();
            if (project != null) window.buildManager().run(project);
        });

        return new ToolBar(build, run);
    }
}
