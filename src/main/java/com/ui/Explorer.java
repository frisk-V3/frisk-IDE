package com.ui;

import javafx.scene.control.TreeItem;
import javafx.scene.control.TreeView;

import java.io.File;

public class Explorer extends TreeView<String> {

    private final MainWindow window;

    public Explorer(MainWindow window) {
        this.window = window;

        setPrefWidth(220);
        setShowRoot(true);

        // クリックでファイルを開く
        setOnMouseClicked(e -> {
            TreeItem<String> item = getSelectionModel().getSelectedItem();
            if (item == null) return;

            File file = resolveFile(item);
            if (file != null && file.isFile()) {
                window.openFile(file.toPath());
            }
        });
    }

    public void loadProject(File rootDir) {
        ExplorerItem root = ExplorerLoader.loadDirectory(rootDir);
        setRoot(root);
        root.setExpanded(true);
    }

    private File resolveFile(TreeItem<String> item) {
        StringBuilder path = new StringBuilder(item.getValue());
        TreeItem<String> parent = item.getParent();

        while (parent != null) {
            path.insert(0, parent.getValue() + File.separator);
            parent = parent.getParent();
        }

        return new File(path.toString());
    }
}
