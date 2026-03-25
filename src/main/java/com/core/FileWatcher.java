package com.core;

import java.nio.file.*;

public class FileWatcher {

    public void watch(Path dir, Runnable onChange) throws Exception {
        WatchService watcher = FileSystems.getDefault().newWatchService();
        dir.register(watcher, StandardWatchEventKinds.ENTRY_MODIFY);

        new Thread(() -> {
            try {
                while (true) {
                    WatchKey key = watcher.take();
                    for (WatchEvent<?> event : key.pollEvents()) {
                        onChange.run();
                    }
                    key.reset();
                }
            } catch (Exception ignored) {}
        }).start();
    }
}
