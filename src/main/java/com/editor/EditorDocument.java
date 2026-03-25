package com.editor;

import java.nio.file.*;

public class EditorDocument {

    private final Path path;
    private String text;

    public EditorDocument(Path path) throws Exception {
        this.path = path;
        this.text = Files.readString(path);
    }

    public Path path() { return path; }
    public String text() { return text; }

    public void text(String t) { this.text = t; }

    public void save() throws Exception {
        Files.writeString(path, text);
    }
}
