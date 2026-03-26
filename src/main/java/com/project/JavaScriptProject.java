package com.project;

import com.core.BuildConfig;
import com.core.Project;

import java.nio.file.Path;

public class JavaScriptProject extends Project {

    public JavaScriptProject(Path root) {
        super(root);

        BuildConfig config = new BuildConfig();
        config.tool("node");
        config.buildCmd(java.util.List.of("npm", "run", "build"));
        config.runCmd(java.util.List.of("npm", "start"));

        buildConfig(config);
    }

    @Override
    public String language() {
        return "javascript";
    }
}
