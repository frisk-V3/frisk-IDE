package com.core;

import java.io.BufferedReader;
import java.io.InputStreamReader;

public class BuildManager {

    public void build(Project project) throws Exception {
        ProcessBuilder pb = new ProcessBuilder(project.buildConfig().buildCmd());
        pb.directory(project.root().toFile());

        Process p = pb.start();

        try (BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()))) {
            String line;
            while ((line = br.readLine()) != null) {
                System.out.println("[BUILD] " + line);
            }
        }
    }
}
