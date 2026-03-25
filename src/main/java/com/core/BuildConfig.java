package com.core;

import java.util.List;

public class BuildConfig {

    private String tool;             // "dotnet", "node", "python" など
    private List<String> buildCmd;   // ["dotnet", "build"]
    private List<String> runCmd;     // ["dotnet", "run"]

    public String tool() { return tool; }
    public void tool(String t) { tool = t; }

    public List<String> buildCmd() { return buildCmd; }
    public void buildCmd(List<String> c) { buildCmd = c; }

    public List<String> runCmd() { return runCmd; }
    public void runCmd(List<String> c) { runCmd = c; }
}
