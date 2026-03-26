package com.ui;

import java.io.File;

public class ExplorerLoader {

    public static ExplorerItem loadDirectory(File dir) {
        ExplorerItem root = new ExplorerItem(dir.getName());

        File[] files = dir.listFiles();
        if (files == null) return root;

        for (File f : files) {
            if (f.isDirectory()) {
                root.getChildren().add(loadDirectory(f));
            } else {
                root.getChildren().add(new ExplorerItem(f.getName()));
            }
        }

        return root;
    }
}
