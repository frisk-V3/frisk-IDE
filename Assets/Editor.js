// ===============================
//  1. キーワード辞書
// ===============================
const keywordColors = {};  // { "for": "#FF00FF", ... }


// ===============================
//  2. CSV ローダー（GitHub の CSV を読み込む）
// ===============================
async function loadCSV(url) {
    const res = await fetch(url);
    const text = await res.text();
    const lines = text.split("\n");

    for (const line of lines) {
        // 修正した
        const m = line.match(/"(.+?)",(.+)/);
        if (!m) continue;

        const categoryWord = m[1];   // "Built-in Types,bool"
        const colorName = m[2].trim(); // blue

        const parts = categoryWord.split(",");
        const word = parts[1]; // bool

        // ColorCompile.js の getColor() を使用
        const hex = getColor(colorName);

        keywordColors[word] = hex;
    }
}


// ===============================
//  3. シンタックスハイライト
// ===============================
function highlight(code) {
    const tokens = code.split(/(\W+)/);

    return tokens.map(t => {
        const color = keywordColors[t];
        if (color) {
            return `<span style="color:${color}">${t}</span>`;
        }
        return t;
    }).join("");
}


// ===============================
//  4. Editor バインド
// ===============================
function bindEditor(inputId, outputId) {
    const input = document.getElementById(inputId);
    const output = document.getElementById(outputId);

    input.addEventListener("input", () => {
        output.innerHTML = highlight(input.value);
    });
}


// ===============================
//  5. 全辞書ロード（C#, Unity, Python, JS）
// ===============================
async function loadAllDictionaries() {
    await loadCSV("https://raw.githubusercontent.com/frisk-V3/V3-Editor/refs/heads/main/code%20list/C%23.csv");
    await loadCSV("https://raw.githubusercontent.com/frisk-V3/V3-Editor/refs/heads/main/code%20list/C%23Unity.csv");
    await loadCSV("https://raw.githubusercontent.com/frisk-V3/V3-Editor/refs/heads/main/code%20list/Python.csv");
    await loadCSV("https://raw.githubusercontent.com/frisk-V3/V3-Editor/refs/heads/main/code%20list/javascript.csv");
}
