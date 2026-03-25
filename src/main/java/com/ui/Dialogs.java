package com.ui;

import javafx.stage.FileChooser;
import javafx.stage.Stage;

import java.io.File;

public class Dialogs {

    public static File openFile(Stage stage) {
        FileChooser chooser = new FileChooser();
        return chooser.showOpenDialog(stage);
    }

    public static File saveFile(Stage stage) {
        FileChooser chooser = new FileChooser();
        return chooser.showSaveDialog(stage);
    }
}
