package com.project;

import com.core.BuildConfig;
import com.core.Project;

import java.nio.file.Path;

public class PythonProject extends Project {

    public PythonProject(Path root) {
        super(root);

        BuildConfig config = new BuildConfig();
        config.tool("python");
        config.buildCmd(java.util.List.of("python", "-m", "py_compile", "main.py"));
        config.runCmd(java.util.List.of("python", "main.py"));

        buildConfig(config);
    }

    @Override
    public String language() {
        return "python";
    }
}
