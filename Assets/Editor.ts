import { keywordColors } from "./ColorCompile";

function escapeHTML(str: string): string {
    return str.replace(/&/g, "&amp;")
              .replace(/</g, "&lt;")
              .replace(/>/g, "&gt;");
}

function tokenize(line: string): string {
    // 改行を削除し、正規表現を一行にまとめました
    return line.split(/(\s+|[(){}\[\];,])/g).filter(t => t.length > 0);
}

function highlightCode(code: string): string {
    const lines = code.split("\n");
    let result = "";

    for (const line of lines) {
        const tokens = tokenize(line);
        let highlighted = "";

        for (const token of tokens) {
            const color = (keywordColors as any)[token]; 
            if (color) {
                highlighted += `<span style="color:${color}">${escapeHTML(token)}</span>`;
            } else {
                highlighted += escapeHTML(token);
            }
        }
        result += highlighted + "\n";
    }
    return result;
}

export function bindEditor(): void {
    const editor = document.getElementById("editor") as HTMLTextAreaElement;
    const highlight = document.getElementById("highlight") as HTMLElement;

    if (editor && highlight) {
        editor.addEventListener("input", () => {
            highlight.innerHTML = highlightCode(editor.value);
        });
    }
}
