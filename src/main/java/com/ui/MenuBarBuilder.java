package com.ui;

import javafx.scene.control.*;

public class MenuBarBuilder {

    public static MenuBar create(MainWindow window) {

        Menu file = new Menu("File");
        file.getItems().addAll(
                new MenuItem("New File"),
                new MenuItem("Open File"),
                new SeparatorMenuItem(),
                new MenuItem("Save"),
                new MenuItem("Save As"),
                new SeparatorMenuItem(),
                new MenuItem("Exit")
        );

        Menu edit = new Menu("Edit");
        edit.getItems().addAll(
                new MenuItem("Undo"),
                new MenuItem("Redo"),
                new SeparatorMenuItem(),
                new MenuItem("Cut"),
                new MenuItem("Copy"),
                new MenuItem("Paste")
        );

        Menu view = new Menu("View");
        view.getItems().addAll(
                new MenuItem("Toggle Sidebar"),
                new MenuItem("Toggle Output")
        );

        Menu build = new Menu("Build");
        build.getItems().addAll(
                new MenuItem("Build Project"),
                new MenuItem("Run Project")
        );

        Menu tools = new Menu("Tools");
        tools.getItems().addAll(
                new MenuItem("Extensions"),
                new MenuItem("Settings")
        );

        Menu help = new Menu("Help");
        help.getItems().addAll(
                new MenuItem("About frisk-IDE")
        );

        return new MenuBar(file, edit, view, build, tools, help);
    }
}
