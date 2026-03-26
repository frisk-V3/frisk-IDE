package com.ui;

import javafx.scene.control.TreeItem;
import javafx.scene.image.ImageView;

public class ExplorerItem extends TreeItem<String> {

    public ExplorerItem(String name) {
        super(name);
    }

    public ExplorerItem(String name, ImageView icon) {
        super(name, icon);
    }
}
