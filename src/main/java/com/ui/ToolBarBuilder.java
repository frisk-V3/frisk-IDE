package com.ui;

import javafx.scene.control.Button;
import javafx.scene.control.ToolBar;

public class ToolBarBuilder {

    public static ToolBar create(MainWindow window) {

        Button newFile = new Button("New");
        Button open = new Button("Open");
        Button save = new Button("Save");
        Button build = new Button("Build");
        Button run = new Button("Run");

        return new ToolBar(newFile, open, save, build, run);
    }
}
