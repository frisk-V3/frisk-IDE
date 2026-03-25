package com.ui;

import javafx.scene.control.TextArea;

public class OutputPane extends TextArea {

    public OutputPane() {
        setEditable(false);
        setStyle("-fx-font-family: 'Consolas'; -fx-font-size: 12;");
    }

    public void log(String text) {
        appendText(text + "\n");
    }
}
