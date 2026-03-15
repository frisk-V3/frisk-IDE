export const ColorTable = {
    purple: "#800080",
    cyan: "#00FFFF",
    red: "#FF0000",
    blue: "#0000FF",
    green: "#008000",
    yellow: "#FFFF00",
    orange: "#FFA500",
    pink: "#FFC0CB",
    white: "#FFFFFF",
    black: "#000000",
    gray: "#808080",
    grey: "#808080"
} as const;

export const keywordColors: Record<string, string> = {};

export function getColor(name: string | null | undefined): string | null {
    if (!name) return null;
    const key = name.toLowerCase().trim();
    return ColorTable[key as keyof typeof ColorTable] ?? null;
}

export async function loadCSV(url: string): Promise<void> {
    const fs = require("fs");
    const text = fs.readFileSync(url, "utf8");

    for (const rawLine of text.split("\n")) {
        const line = rawLine.trim();
        if (!line || line.startsWith("#")) continue;

        const m = line.match(/^"?(.*?)"?\s*,\s*(.+)$/);
        if (!m) continue;

        const word = m[1].trim();
        const colorName = m[2].trim();

        const hex = getColor(colorName);
        if (hex) keywordColors[word] = hex;
    }
}

export async function loadAllDictionaries(): Promise<void> {
    const base = "code list/";

    const files = [
        "C#.csv",
        "C#Unity.csv",
        "Python.csv",
        "javascript.csv"
    ];

    for (const file of files) {
        await loadCSV(base + file);
    }
}
