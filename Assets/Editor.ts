// ===============================
//  1. キーワード辞書（型安全）
// ===============================
export const keywordColors: Record<string, string> = {};


// ===============================
//  2. CSV ローダー（バグ修正 & 強化）
// ===============================
export async function loadCSV(url: string): Promise<void> {
    const res = await fetch(url);
    const text = await res.text();

    for (const line of text.split("\n")) {
        const trimmed = line.trim();
        if (!trimmed || trimmed.startsWith("#")) continue;

        // "AAA,BBB",ColorName
        const m = trimmed.match(/^"(.+?)"\s*,\s*(.+)$/);
        if (!m) continue;

        const categoryWord = m[1];   // AAA,BBB
        const colorName = m[2].trim();

        // CSV の1列目は "カテゴリ,単語" の形式
        const parts = categoryWord.split(",");
        const word = parts[1] ?? parts[0]; // ← parts[1] が無い場合のバグ修正

        const hex = getColor(colorName);
        if (hex) {
            keywordColors[word] = hex;
        }
    }
}


// ===============================
//  3. トークン分割（正規表現修正）
// ===============================
export function tokenize(code: string): string[] {
    return code.split(
        /(\s+|==|!=|<=|>=|=>|::|->|\.\.|\.|,|\(|\)|\{|\}|

\[|\]

|;|\+|-|\*|\/|%|&|\||\^|!|<|>|\?|:)/
    );
}


// ===============================
//  4. HTML エスケープ（XSS 対策）
// ===============================
function escapeHTML(str: string): string {
    return str
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;");
}


// ===============================
//  5. シンタックスハイライト
// ===============================
export function highlightCode(code: string): string {
    const tokens = tokenize(code);

    return tokens
        .map(t => {
            const color = keywordColors[t];
            if (color) {
                return `<span style="color:${color}">${escapeHTML(t)}</span>`;
            }
            return escapeHTML(t);
        })
        .join("");
}


// ===============================
//  6. Editor バインド（IDE 方式）
// ===============================
export function bindEditor(): void {
    const input = document.getElementById("editor") as HTMLTextAreaElement;
    const highlight = document.getElementById("highlight") as HTMLElement;

    if (!input || !highlight) return;

    input.addEventListener("input", () => {
        highlight.innerHTML = highlightCode(input.value);
    });

    input.addEventListener("scroll", () => {
        highlight.scrollTop = input.scrollTop;
        highlight.scrollLeft = input.scrollLeft;
    });
}


// ===============================
//  7. 全辞書ロード（並列ロード）
// ===============================
export async function loadAllDictionaries(): Promise<void> {
    const urls = [
        "https://raw.githubusercontent.com/frisk-V3/V3-Editor/refs/heads/main/code%20list/C%23.csv",
        "https://raw.githubusercontent.com/frisk-V3/V3-Editor/refs/heads/main/code%20list/C%23Unity.csv",
        "https://raw.githubusercontent.com/frisk-V3/V3-Editor/refs/heads/main/code%20list/Python.csv",
        "https://raw.githubusercontent.com/frisk-V3/V3-Editor/refs/heads/main/code%20list/javascript.csv"
    ];

    await Promise.all(urls.map(loadCSV));
}
