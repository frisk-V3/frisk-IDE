package com.utils;

import java.io.IOException;
import java.nio.file.*;

public class FileUtils {

    public static String read(Path path) throws IOException {
        return Files.readString(path);
    }

    public static void write(Path path, String text) throws IOException {
        Files.writeString(path, text, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
    }

    public static boolean exists(Path path) {
        return Files.exists(path);
    }

    public static void ensureDir(Path dir) throws IOException {
        if (!Files.exists(dir)) Files.createDirectories(dir);
    }

    public static void copy(Path src, Path dst) throws IOException {
        Files.copy(src, dst, StandardCopyOption.REPLACE_EXISTING);
    }

    public static void delete(Path path) throws IOException {
        Files.deleteIfExists(path);
    }
}
