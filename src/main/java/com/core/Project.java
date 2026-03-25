package com.core;

import java.nio.file.Path;

public class Project {

    private final Path root;
    private BuildConfig buildConfig;

    public Project(Path root) {
        this.root = root;
    }

    public Path root() { return root; }

    public BuildConfig buildConfig() { return buildConfig; }
    public void buildConfig(BuildConfig config) { this.buildConfig = config; }
}
