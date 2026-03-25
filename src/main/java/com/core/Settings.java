package com.core;

public class Settings {

    private String theme = "dark";
    private String font = "JetBrains Mono";
    private int fontSize = 14;
    private boolean autoSave = true;

    public String theme() { return theme; }
    public void theme(String t) { theme = t; }

    public String font() { return font; }
    public void font(String f) { font = f; }

    public int fontSize() { return fontSize; }
    public void fontSize(int s) { fontSize = s; }

    public boolean autoSave() { return autoSave; }
    public void autoSave(boolean a) { autoSave = a; }
}
