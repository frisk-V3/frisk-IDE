package com.project;

import com.core.BuildConfig;
import com.core.Project;

import java.nio.file.Path;

public class CSharpProject extends Project {

    public CSharpProject(Path root) {
        super(root);

        BuildConfig config = new BuildConfig();
        config.tool("dotnet");
        config.buildCmd(java.util.List.of("dotnet", "build"));
        config.runCmd(java.util.List.of("dotnet", "run"));

        buildConfig(config);
    }

    @Override
    public String language() {
        return "csharp";
    }
}
