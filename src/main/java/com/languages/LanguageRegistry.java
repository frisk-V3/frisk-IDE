package com.languages;

import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

public class LanguageRegistry {

    private static final Map<String, LanguageDefinition> byExtension = new HashMap<>();

    public static void register(LanguageDefinition def) {
        for (String ext : def.extensions) {
            byExtension.put(ext.toLowerCase(), def);
        }
    }

    public static LanguageDefinition getByExtension(String ext) {
        return byExtension.get(ext.toLowerCase());
    }

    public static void loadFromFolder(Path folder) throws Exception {
        var files = folder.toFile().listFiles((d, name) -> name.endsWith(".json"));
        if (files == null) return;

        for (var f : files) {
            LanguageDefinition def = LanguageLoader.load(f.toPath());
            register(def);
        }
    }
}
